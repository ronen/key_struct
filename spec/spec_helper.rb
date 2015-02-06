if RUBY_VERSION > "1.9"
  require 'simplecov'
  require 'simplecov-gem-profile'
  SimpleCov.start 'gem'
end

require 'rspec'
require 'key_struct'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  
end
