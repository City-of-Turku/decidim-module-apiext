# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe UpdateProposalClassificationsType, type: :graphql do
      include_context "with a graphql class mutation"

      let(:root_klass) { Decidim::Proposals::ProposalMutationType }
      let(:organization) { current_organization }
      let(:participatory_process) do
        create(:participatory_process, :with_steps, organization:)
      end
      let(:component) do
        create(:proposal_component, participatory_space: participatory_process)
      end
      let!(:model) { create(:proposal, :published, component:) }

      let(:current_user) { create(:user, :confirmed, :admin, organization:) }

      let(:scope_id) { nil }
      let(:category_id) { nil }

      let(:arguments) do
        {
          scopeId: scope_id,
          categoryId: category_id
        }.compact
      end

      let(:query) do
        <<~GRAPHQL
          mutation {
            updateClassifications(input: {
              #{arguments.map { |key, value| "#{key}: #{value.to_json}" }.join(", ")}
            }) {
              id
            }
          }
        GRAPHQL
      end

      before do
        allow(Decidim::Proposals::Admin::UpdateProposalScope)
          .to receive(:call)

        allow(Decidim::Proposals::Admin::UpdateProposalCategory)
          .to receive(:call)
      end

      context "when no classifications are provided" do
        it "returns the proposal without updating classifications" do
          expect(Decidim::Proposals::Admin::UpdateProposalScope)
            .not_to receive(:call)

          expect(Decidim::Proposals::Admin::UpdateProposalCategory)
            .not_to receive(:call)

          expect(response["updateClassifications"]["id"])
            .to eq(model.id.to_s)
        end
      end

      context "when only a scope is provided" do
        let(:scope_id) { "123" }

        it "updates the proposal scope" do
          expect(Decidim::Proposals::Admin::UpdateProposalScope)
            .to receive(:call)
            .with(scope_id, [model.id])

          expect(Decidim::Proposals::Admin::UpdateProposalCategory)
            .not_to receive(:call)

          expect(response["updateClassifications"]["id"])
            .to eq(model.id.to_s)
        end
      end

      context "when only a category is provided" do
        let(:category_id) { "456" }

        it "updates the proposal category" do
          expect(Decidim::Proposals::Admin::UpdateProposalCategory)
            .to receive(:call)
            .with(category_id, [model.id])

          expect(Decidim::Proposals::Admin::UpdateProposalScope)
            .not_to receive(:call)

          expect(response["updateClassifications"]["id"])
            .to eq(model.id.to_s)
        end
      end

      context "when both scope and category are provided" do
        let(:scope_id) { "123" }
        let(:category_id) { "456" }

        it "updates both classifications" do
          expect(Decidim::Proposals::Admin::UpdateProposalScope)
            .to receive(:call)
            .with(scope_id, [model.id])

          expect(Decidim::Proposals::Admin::UpdateProposalCategory)
            .to receive(:call)
            .with(category_id, [model.id])

          expect(response["updateClassifications"]["id"])
            .to eq(model.id.to_s)
        end
      end

      context "when updating the scope fails" do
        let(:scope_id) { "123" }

        before do
          allow(Decidim::Proposals::Admin::UpdateProposalScope)
            .to receive(:call)
            .and_raise(ActiveRecord::RecordInvalid)
        end

        it "returns the scope error" do
          expect { response }.to raise_error(
            StandardError,
            /#{Regexp.escape(I18n.t("proposals.update_scope.select_a_scope", scope: "decidim.proposals.admin"))}/
          )
        end
      end

      context "when updating the category fails" do
        let(:category_id) { "456" }

        before do
          allow(Decidim::Proposals::Admin::UpdateProposalCategory)
            .to receive(:call)
            .and_raise(ActiveRecord::RecordInvalid)
        end

        it "returns the category error" do
          expect { response }.to raise_error(
            StandardError,
            /#{Regexp.escape(I18n.t("proposals.update_category.select_a_category", scope: "decidim.proposals.admin"))}/
          )
        end
      end

      context "when both updates fail" do
        let(:scope_id) { "123" }
        let(:category_id) { "456" }

        before do
          allow(Decidim::Proposals::Admin::UpdateProposalScope)
            .to receive(:call)
            .and_raise(StandardError, "Scope failed")

          allow(Decidim::Proposals::Admin::UpdateProposalCategory)
            .to receive(:call)
            .and_raise(StandardError, "Category failed")
        end

        it "includes both validation messages" do
          scope_message = I18n.t(
            "proposals.update_scope.select_a_scope",
            scope: "decidim.proposals.admin"
          )
          category_message = I18n.t(
            "proposals.update_category.select_a_category",
            scope: "decidim.proposals.admin"
          )

          expect { response }.to raise_error(
            StandardError,
            /#{Regexp.escape(scope_message)}.*#{Regexp.escape(category_message)}/
          )
        end
      end

      context "when the user is not an admin" do
        let(:current_user) { create(:user, :confirmed, organization:) }

        it "rejects the mutation" do
          expect { response }.to raise_error(
            StandardError,
            I18n.t("decidim.api.errors.unauthorized_mutation")
          )
        end
      end

      context "when the user is anonymous" do
        let(:current_user) { nil }

        it "rejects the mutation" do
          expect { response }.to raise_error(
            StandardError,
            I18n.t("decidim.api.errors.unauthorized_mutation")
          )
        end
      end
    end
  end
end
