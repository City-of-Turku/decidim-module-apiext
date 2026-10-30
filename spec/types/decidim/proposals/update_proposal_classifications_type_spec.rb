# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe UpdateProposalClassificationsType, type: :graphql do
      include_context "with a graphql class mutation"
      let(:organization) { current_organization }
      let(:root_klass) { Decidim::Proposals::ProposalMutationType }
      let(:participatory_process) do
        create(:participatory_process, :with_steps, organization:)
      end
      let(:component) do
        create(:proposal_component, participatory_space: participatory_process)
      end

      let(:admin) { create(:user, :confirmed, :admin, organization:) }
      let(:current_user) { admin }

      let!(:model) do
        create(:proposal, :published, component:)
      end

      let(:taxonomy_root) do
        create(:taxonomy, organization:)
      end

      let(:taxonomy) do
        create(:taxonomy, organization:, parent: taxonomy_root)
      end

      let(:another_taxonomy) do
        create(:taxonomy, organization:, parent: taxonomy_root)
      end

      let(:taxonomy_ids) { [taxonomy.id.to_s] }

      let(:query) do
        <<~GRAPHQL
          mutation {
            updateClassifications(input: {
              taxonomies: #{taxonomy_ids.to_json}
            }) {
              id
              taxonomies {
                id
              }
            }
          }
        GRAPHQL
      end

      context "when the user is an admin" do
        context "with valid taxonomies" do
          let(:taxonomy_ids) do
            [taxonomy.id.to_s, another_taxonomy.id.to_s]
          end

          it "updates the proposal taxonomies" do
            expect(response["updateClassifications"]).to be_present

            expect(response["updateClassifications"]["id"]).to eq(model.id.to_s)

            expect(
              response["updateClassifications"]["taxonomies"].pluck("id")
            ).to match_array(taxonomy_ids)

            expect(model.reload.taxonomy_ids.map(&:to_s)).to match_array(taxonomy_ids)
          end
        end

        context "when the taxonomies are unchanged" do
          before do
            model.update!(taxonomies: [taxonomy])
          end

          it "returns the proposal without an error" do
            expect(response["updateClassifications"]).to be_present
            expect(response["updateClassifications"]["id"]).to eq(model.id.to_s)
            expect(model.reload.taxonomy_ids).to eq([taxonomy.id])
          end
        end

        context "when the taxonomy is invalid" do
          let(:taxonomy_ids) { ["999999999"] }

          it "raises a GraphQL execution error" do
            expect { response }.to raise_error(
              GraphQL::ExecutionError,
              I18n.t(
                "proposals.update_taxonomies.select_a_taxonomy",
                scope: "decidim.proposals.admin"
              )
            )
          end

          it "does not update the proposal" do
            expect { response }.to raise_error(GraphQL::ExecutionError)
            expect(model.reload.taxonomy_ids).to be_empty
          end
        end

        context "when the taxonomy list is empty" do
          let(:taxonomy_ids) { [] }

          it "raises a GraphQL execution error" do
            expect { response }.to raise_error(
              GraphQL::ExecutionError,
              I18n.t(
                "proposals.update_taxonomies.select_a_taxonomy",
                scope: "decidim.proposals.admin"
              )
            )
          end
        end
      end

      context "when the user is not an admin" do
        let(:current_user) do
          create(:user, :confirmed, organization:)
        end

        it "raises a MutationNotAuthorizedError" do
          expect { response }.to raise_error(
            Decidim::Api::Errors::MutationNotAuthorizedError,
            I18n.t("decidim.api.errors.unauthorized_mutation")
          )
        end

        it "does not update the proposal" do
          expect { response }.to raise_error(
            Decidim::Api::Errors::MutationNotAuthorizedError
          )

          expect(model.reload.taxonomy_ids).to be_empty
        end
      end

      context "when the user is anonymous" do
        let(:current_user) { nil }

        it "raises a MutationNotAuthorizedError" do
          expect { response }.to raise_error(
            Decidim::Api::Errors::MutationNotAuthorizedError
          )
        end
      end
    end
  end
end
