# frozen_string_literal: true

require 'method_source'

module AppMap
  class ClassMap
    module HasChildren
      def self.included(base)
        base.module_eval do
          def children
            @children ||= []
          end
        end
      end
    end

    module Types
      class Root
        include HasChildren
      end

      Package = Struct.new(:name) do
        include HasChildren

        def type
          'package'
        end

        def to_h
          {
            name: name,
            type: type,
            children: children.map(&:to_h)
          }
        end
      end
      Class = Struct.new(:name) do
        include HasChildren

        def type
          'class'
        end

        def to_h
          {
            name: name,
            type: type,
            children: children.map(&:to_h)
          }
        end
      end
      Function = Struct.new(:name) do
        attr_accessor :static, :location, :labels, :comment, :source

        def type
          'function'
        end

        def to_h
          {
            name: name,
            type: type,
            location: location,
            static: static,
            labels: labels,
            comment: comment,
            source: source
          }.delete_if { |_, v| v.nil? || v == [] }
        end
      end
    end

    class << self
      def build_from_methods(methods)
        root = Types::Root.new
        methods.each do |method|
          add_function root, method
        end
        root.children.map(&:to_h)
      end

      protected

      def add_function(root, method)
        package = method.package
        static = method.static

        object_infos = [
          {
            name: package.name,
            type: 'package'
          }
        ]
        object_infos += method.defined_class.split('::').map do |name|
          {
            name: name,
            type: 'class'
          }
        end
        function_info = {
          name: method.name,
          type: 'function',
          static: static
        }
        location = method.source_location

        function_info[:location] = \
          if location
            location_file, lineno = location
            location_file = location_file[Dir.pwd.length + 1..-1] if location_file.index(Dir.pwd) == 0
            [ location_file, lineno ].join(':')
          else
            [ method.defined_class, static ? '.' : '#', method.name ].join
          end

        comment = begin
          method.comment
        rescue MethodSource::SourceNotFoundError
          nil
        end

        function_info[:comment] = comment unless comment.blank?

        function_info[:labels] = parse_labels(comment) + (package.labels || [])
        object_infos << function_info

        parent = root
        object_infos.each do |info|
          parent = find_or_create parent.children, info do
            Types.const_get(info[:type].classify).new(info[:name].to_s).tap do |type|
              info.keys.tap do |keys|
                keys.delete(:name)
                keys.delete(:type)
              end.each do |key|
                type.send "#{key}=", info[key]
              end
            end
          end
        end
      end

      # Labels can be embedded in the function comment. Label format is similar to YARD and JavaDoc.
      # The keyword is @labels or @label. The keyword is followed by space-separated labels.
      # For example:
      # @label provider.authentication security
      def parse_labels(comment)
        return [] unless comment

        comment
          .split("\n")
          .map { |line| line.match(/^\s*#\s*@labels?\s+(.*)/) }
          .compact
          .map { |match| match[1] }
          .inject([]) { |accum, labels| accum += labels.split(/\s+/); accum }
          .sort
      end

      def find_or_create(list, info)
        obj = list.find { |item| item.type == info[:type] && item.name == info[:name] }
        return obj if obj

        yield.tap do |new_obj|
          list << new_obj
        end
      end
    end
  end
end
