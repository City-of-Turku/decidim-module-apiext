# frozen_string_literal: true

require "spec_helper"
require "rails/generators"
require "generators/decidim/apiext/install_generator"

describe Decidim::Apiext::Generators::InstallGenerator do
  let(:secrets_path) { Rails.application.root.join("config", "secrets.yml") }
  let(:options) { { test_initializer: true } }
  let(:orginal_lines) { %w(test: development: production:) }
  let(:example_token) { "1o3m3g7" }
  let(:final_lines) { ["test:", "development:", "production:", "  secret_key_jwt: 1o3m3g7\n"] }

  it "adds secret_key_jwt to the secrets.yml file" do
    # rubocop:disable RSpec/SubjectStub
    allow(subject).to receive(:options).and_return(options)
    # rubocop:enable RSpec/SubjectStub
    allow(SecureRandom).to receive(:hex).and_return(example_token)
    allow(YAML).to receive(:safe_load).and_return({})
    allow(IO).to receive(:readlines).and_return(orginal_lines)
    expect(File).to receive(:open).with(Rails.application.root.join("config", "secrets.yml"), "w") do |&block|
      file = double
      expect(file).to receive(:puts).with(final_lines)
      block.call(file)
    end

    subject.add_jwt_secret
  end
end
