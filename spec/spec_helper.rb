require 'rspec'
require 'net/http'
require 'json'
require 'yaml'
require 'English'
require 'byebug'
require 'webdrivers/chromedriver'

# Disable default initialization of AppMap
ENV['APPMAP_INITIALIZE'] = 'false'

require 'appmap'

RSpec.configure do |config|
  config.example_status_persistence_file_path = "tmp/rspec_failed_examples.txt"
end

# Re-run the Rails specs without re-generating the data. This is useful for efficiently enhancing and
# debugging the test itself.
def use_existing_data?
  ENV['USE_EXISTING_DATA'] == 'true'
end
