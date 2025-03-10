# frozen_string_literal: true

module AppMap
  class Hook
    class Method
      attr_reader :hook_package, :hook_class, :hook_method

      # +method_display_name+ may be nil if name resolution gets
      # deferred until runtime (e.g. for a singleton method on an
      # embedded Struct).
      attr_reader :method_display_name

      HOOK_DISABLE_KEY = 'AppMap::Hook.disable'
      private_constant :HOOK_DISABLE_KEY

      # Grab the definition of Time.now here, to avoid interfering
      # with the method we're hooking.
      TIME_NOW = Time.method(:now)
      private_constant :TIME_NOW

      def initialize(hook_package, hook_class, hook_method)
        @hook_package = hook_package
        @hook_class = hook_class
        @hook_method = hook_method

        # Get the class for the method, if it's known.
        @defined_class, method_symbol = Hook.qualify_method_name(@hook_method)
        @method_display_name = [@defined_class, method_symbol, @hook_method.name].join if @defined_class
      end

      def activate
        if Hook::LOG
          msg = if method_display_name
                  "#{method_display_name}"
                else
                  "#{hook_method.name} (class resolution deferred)"
                end
          warn "AppMap: Hooking #{msg} at line #{(hook_method.source_location || []).join(':')}"
        end

        defined_class = @defined_class
        hook_package = self.hook_package
        hook_method = self.hook_method
        before_hook = self.method(:before_hook)
        after_hook = self.method(:after_hook)
        with_disabled_hook = self.method(:with_disabled_hook)

        hook_method_def = nil
        hook_class.instance_eval do 
          hook_method_def = Proc.new do |*args, &block|
            instance_method = hook_method.bind(self).to_proc
            call_instance_method = -> { instance_method.call(*args, &block) }

            # We may not have gotten the class for the method during
            # initialization (e.g. for a singleton method on an embedded
            # struct), so make sure we have it now.
            defined_class, = Hook.qualify_method_name(hook_method) unless defined_class

            reentrant = Thread.current[HOOK_DISABLE_KEY]
            disabled_by_shallow_flag = \
              -> { hook_package&.shallow? && AppMap.tracing.last_package_for_current_thread == hook_package }

            enabled = true if AppMap.tracing.enabled? && !reentrant && !disabled_by_shallow_flag.call

            return call_instance_method.call unless enabled

            call_event, start_time = with_disabled_hook.call do
              before_hook.call(self, defined_class, args)
            end
            return_value = nil
            exception = nil
            begin
              return_value = call_instance_method.call
            rescue
              exception = $ERROR_INFO
              raise
            ensure
              with_disabled_hook.call do
                after_hook.call(self, call_event, start_time, return_value, exception)
              end
            end
          end
        end
        hook_class.define_method_with_arity(hook_method.name, hook_method.arity, hook_method_def)
      end

      protected

      def before_hook(receiver, defined_class, args)
        require 'appmap/event'
        call_event = AppMap::Event::MethodCall.build_from_invocation(defined_class, hook_method, receiver, args)
        AppMap.tracing.record_event call_event, package: hook_package, defined_class: defined_class, method: hook_method
        [ call_event, TIME_NOW.call ]
      end

      def after_hook(_receiver, call_event, start_time, return_value, exception)
        require 'appmap/event'
        elapsed = TIME_NOW.call - start_time
        return_event = \
          AppMap::Event::MethodReturn.build_from_invocation call_event.id, elapsed, return_value, exception
        AppMap.tracing.record_event return_event
      end

      def with_disabled_hook(&function)
        # Don't record functions, such as to_s and inspect, that might be called
        # by the fn. Otherwise there can be a stack overflow.
        Thread.current[HOOK_DISABLE_KEY] = true
        begin
          function.call
        ensure
          Thread.current[HOOK_DISABLE_KEY] = false
        end
      end
    end
  end
end
