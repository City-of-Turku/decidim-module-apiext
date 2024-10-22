# frozen_string_literal: true

require "spec_helper"
require "rails/generators"
require "generators/decidim/apiext/install_generator"

describe Decidim::Apiext::Generators::InstallGenerator do
  let(:secrets_path) { Rails.application.root.join("config", "secrets.yml") }
  let(:example_token) { "1o3m3g7" }
  let(:config_contents) do
    <<~CONFIG.strip
      test:
        secret: test
        foo: bar

      development:
        secret: dev
        bar: baz

      production:
        secret: abc
    CONFIG
  end
  let(:expected_contents) do
    <<~CONFIG.strip
      test:
        secret: test
        foo: bar
        secret_key_jwt: #{example_token}


      development:
        secret: dev
        bar: baz
        secret_key_jwt: #{example_token}


      production:
        secret: abc
    CONFIG
  end

  it "adds secret_key_jwt to the secrets.yml file" do
    allow(SecureRandom).to receive(:hex).and_return(example_token)
    allow(YAML).to receive(:safe_load).and_return({})
    final = config_contents
    allow(IO).to receive(:readlines) { final.split("\n") }
    expect(File).to receive(:open).twice.with(Rails.application.root.join("config", "secrets.yml"), "w") do |&block|
      file = double
      allow(file).to receive(:puts) { |data| final = data.join("\n") }
      block.call(file)
    end

    subject.add_jwt_secret

    expect(final).to eq(expected_contents)
  end
end
