# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

# This test is here to test the local fix for this bug:
# https://github.com/decidim/decidim/pull/15170
describe Decidim::Accountability::ResultType, type: :graphql do
  include_context "with a graphql class type"

  let(:model) { create(:result) }
  let(:organization) { model.organization }

  include_examples "commentable interface"
end
