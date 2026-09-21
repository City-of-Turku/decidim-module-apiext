# frozen_string_literal: true

require "decidim/dev"

ENV["ENGINE_ROOT"] = File.dirname(__dir__)

Decidim::Dev.dummy_app_path =
  File.expand_path(File.join(__dir__, "decidim_dummy_app"))

require "decidim/dev/test/base_spec_helper"

Decidim::Api.schema_max_depth = 15
Decidim::Api.schema_max_complexity = 5000
Decidim::Api::RecursionAnalyzer.send(:remove_const, :RECURSION_THRESHOLD)
Decidim::Api::RecursionAnalyzer::RECURSION_THRESHOLD = 4
