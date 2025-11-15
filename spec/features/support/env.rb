ENV["RAILS_ENV"] ||= "test"
ENV["RAILS_ROOT"] = File.expand_path("../../..", __dir__)
require File.expand_path("../../../config/environment", __dir__)

require "cucumber/rails"
require "rspec"
require "rspec/mocks/standalone"
require "factory_bot_rails"
require "rack/test"
require "database_cleaner/active_record"

ActionController::Base.allow_forgery_protection = false
Rails.application.routes.default_url_options[:host] = "example.test"

DatabaseCleaner.strategy = :transaction
Cucumber::Rails::Database.javascript_strategy = :truncation

World(FactoryBot::Syntax::Methods)
World(RSpec::Matchers)
World(RSpec::Mocks::ExampleMethods)

Before do
  DatabaseCleaner.start
  RSpec::Mocks.setup
end

After do
  DatabaseCleaner.clean
  RSpec::Mocks.verify
  RSpec::Mocks.teardown
end
