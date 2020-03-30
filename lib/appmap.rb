# frozen_string_literal: true

begin
  require 'active_support'
  require 'active_support/core_ext'
rescue NameError
  warn 'active_support is not available. AppMap execution will continue optimistically without it...'
end

require 'appmap/version'

module AppMap
  BATCH_HEADER_NAME = 'AppLand-Scenario-Batch'

  class << self
    def configure(config_file_path = 'appmap.yml')
      warn "Configuring AppMap from path #{config_file_path}"
      require 'appmap/hook'
      AppMap::Hook::Config.load_from_file(config_file_path)
    end

    # class_map returns the class map of code which is referenced by an event list.
    # If the event list is empty or nil, all code which was loaded by the program is included
    # in the result.
    def class_map(events)
      # TODO: Generate the class map
      []
    end

    # Simplified entry point to add hooks to code as it's loaded.
    def hook(config = configure)
      require 'appmap/hook'
      AppMap::Hook.hook(config)
    end
  end
end

require 'appmap/railtie' if defined?(::Rails::Railtie)
