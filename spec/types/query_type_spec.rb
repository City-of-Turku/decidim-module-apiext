# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim::Api
  describe QueryType do
    include_context "with a graphql class type"

    describe "commentable" do
      let(:model) { create(:proposal) }
      let(:query) { %({ commentable(type: "#{model.commentable_type}", id: "#{id}", locale: "#{locale}", toggleTranslations: false) { id } }) }
      let(:id) { model.id }
      let(:locale) { "en" }

      it "returns the commentable response" do
        expect(response["commentable"]).to eq("id" => model.id.to_s)
      end

      context "with unknown locale" do
        let(:locale) { "tlh" }

        it "returns a proper GraphQL error" do
          expect { response }.to raise_error("#{locale} is not a valid locale")
        end
      end

      context "with unknown record id" do
        let(:id) { model.id + 1000 }

        it "returns nothing" do
          expect(response["commentable"]).to be_nil
        end
      end
    end
  end
end
