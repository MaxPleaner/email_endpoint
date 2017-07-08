# Custom helper methods are found in test_helpers.rb
# RSpec config stuff is in this file, spec_helper.rb
require_relative './test_helpers.rb'

# require the main server class as well
require_relative '../server.rb'

RSpec.configure do |config|

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

end