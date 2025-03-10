# frozen_string_literal: true

require 'appmap/event'
require 'appmap/hook'

module AppMap
  module Rails
    module RequestHandler
      # Host and User-Agent will just introduce needless variation.
      # Content-Type and Authorization get their own fields in the request.
      IGNORE_HEADERS = %w[host user_agent content_type authorization].map(&:upcase).map {|h| "HTTP_#{h}"}.freeze

      class << self
        def selected_headers(env)
          # Rack prepends HTTP_ to all client-sent headers.
          matching_headers = env
            .select { |k,v| k.start_with? 'HTTP_'}
            .reject { |k,v| IGNORE_HEADERS.member?(k) }
            .reject { |k,v| v.blank? }
            .each_with_object({}) do |kv, memo|
              key = kv[0].sub(/^HTTP_/, '').split('_').map(&:capitalize).join('-')
              value = kv[1]
              memo[key] = value
            end
          matching_headers.blank? ? nil : matching_headers
        end
      end

      class HTTPServerRequest < AppMap::Event::MethodEvent
        attr_accessor :normalized_path_info, :request_method, :path_info, :params, :mime_type, :headers, :authorization

        def initialize(request)
          super AppMap::Event.next_id_counter, :call, Thread.current.object_id

          self.request_method = request.request_method
          self.normalized_path_info = normalized_path(request)
          self.mime_type = request.headers['Content-Type']
          self.headers = RequestHandler.selected_headers(request.env)
          self.authorization = request.headers['Authorization']
          self.path_info = request.path_info.split('?')[0]
          # ActionDispatch::Http::ParameterFilter is deprecated
          parameter_filter_cls = \
            if defined?(ActiveSupport::ParameterFilter)
              ActiveSupport::ParameterFilter
            else
              ActionDispatch::Http::ParameterFilter
            end
          self.params = parameter_filter_cls.new(::Rails.application.config.filter_parameters).filter(request.params)
        end

        def to_h
          super.tap do |h|
            h[:http_server_request] = {
              request_method: request_method,
              path_info: path_info,
              mime_type: mime_type,
              normalized_path_info: normalized_path_info,
              authorization: authorization,
              headers: headers,
            }.compact

            h[:message] = params.keys.map do |key|
              val = params[key]
              {
                name: key,
                class: val.class.name,
                value: self.class.display_string(val),
                object_id: val.__id__,
              }.tap do |message|
                properties = object_properties(val)
                message[:properties] = properties if properties
              end
            end
          end
        end

        private

        def normalized_path(request, router = ::Rails.application.routes.router)
          router.recognize request do |route, _|
            app = route.app
            next unless app.matches? request
            return normalized_path request, app.rack_app.routes.router if app.engine?

            return route.path.spec.to_s
          end
        end
      end

      class HTTPServerResponse < AppMap::Event::MethodReturnIgnoreValue
        attr_accessor :status, :mime_type, :headers

        def initialize(response, parent_id, elapsed)
          super AppMap::Event.next_id_counter, :return, Thread.current.object_id

          self.status = response.status
          self.mime_type = response.headers['Content-Type']
          self.parent_id = parent_id
          self.elapsed = elapsed
          self.headers = RequestHandler.selected_headers(response.headers)
        end

        def to_h
          super.tap do |h|
            h[:http_server_response] = {
              status: status,
              mime_type: mime_type,
              headers: headers
            }.compact
          end
        end
      end

      class HookMethod < AppMap::Hook::Method
        def initialize
          # ActionController::Instrumentation has issued start_processing.action_controller and
          # process_action.action_controller since Rails 3. Therefore it's a stable place to hook
          # the request. Rails controller notifications can't be used directly because they don't
          # provide response headers, and we want the Content-Type.
          super(nil, ActionController::Instrumentation, ActionController::Instrumentation.instance_method(:process_action))
        end

        protected

        def before_hook(receiver, defined_class, _) # args
          call_event = HTTPServerRequest.new(receiver.request)
          # http_server_request events are i/o and do not require a package name.
          AppMap.tracing.record_event call_event, defined_class: defined_class, method: hook_method
          [ call_event, TIME_NOW.call ]
        end

        def after_hook(receiver, call_event, start_time, _, _) # return_value, exception
          elapsed = TIME_NOW.call - start_time
          return_event = HTTPServerResponse.new receiver.response, call_event.id, elapsed
          AppMap.tracing.record_event return_event
        end
      end
    end
  end
end
