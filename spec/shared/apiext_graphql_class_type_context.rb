# frozen_string_literal: true

RSpec.shared_context "with apiext graphql mutation type" do
  include_context "with a graphql class mutation"

  def raise_proper_error(error)
    code = error.dig("extensions", "code")

    if %w(
      INTROSPECTION_DISABLED_ERROR
      TOO_MANY_ALIASES_ERROR
      RECURSION_LIMIT_EXCEEDED_ERROR
      MUTATION_NOT_AUTHORIZED_ERROR
    ).include?(code)
      raise "Decidim::Api::Errors::#{code.downcase.classify}".constantize, error["message"]
    end

    raise GraphQL::ExecutionError, error["message"]
  end
end
