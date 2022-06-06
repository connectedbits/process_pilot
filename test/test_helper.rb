# frozen_string_literal: true

# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

ROOT = File.join(File.dirname(__FILE__), "..")

require_relative "../lib/processable"
require "minitest/autorun"
require "minitest/reporters"
require "minitest-spec-rails"
require "mocha"
require 'rails/test_unit/reporter'
require "active_support/testing/time_helpers"

Time.zone_default = Time.find_zone!("UTC")

# ActiveRecord::Migrator.migrations_paths = [File.expand_path("../test/dummy/db/migrate", __dir__)]

# # Load fixtures from the engine
# if ActiveSupport::TestCase.respond_to?(:fixture_path=)
#   ActiveSupport::TestCase.fixture_path = File.expand_path("fixtures", __dir__)
#   ActionDispatch::IntegrationTest.fixture_path = ActiveSupport::TestCase.fixture_path
#   ActiveSupport::TestCase.file_fixture_path = ActiveSupport::TestCase.fixture_path + "/files"
#   ActiveSupport::TestCase.fixtures :all
# end

Rails::TestUnitReporter.executable = 'bin/test'

class Minitest::Spec
  include ActiveSupport::Testing::TimeHelpers

  before :each do
  end

  after :each do
  end
end

Minitest::Reporters.use!(
  Minitest::Reporters::ProgressReporter.new(color: true),
    ENV,
    Minitest.backtrace_filter,
)

def fixture_source(filename)
  File.read("#{ROOT}/test/fixtures/files/#{filename}")
end
