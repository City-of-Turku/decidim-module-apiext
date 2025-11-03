# frozen_string_literal: true

shared_examples "manage proposal answer mutation examples" do
  context "when non admin user is logged in" do
    describe "try to answer to porposal" do
      it "raises error" do
        expect { response }.to raise_error(Decidim::Apiext::ActionForbidden)
      end
    end
  end

  context "when admin is logged in" do
    before do
      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(described_class).to receive(:current_user).and_return(user)
      # rubocop:enable RSpec/AnyInstance
    end

    describe "answer to proposal" do
      it "changes proposals state" do
        expect(response["answer"]).to include("id" => model.id.to_s)
        expect(response["answer"]).to include("state" => state)
        answer = Decidim::Proposals::Proposal.find(model.id).answer
        expect(answer["en"]).to eq(answer_en)
        expect(answer["fi"]).to eq(answer_fi)
        expect(answer["sv"]).to eq(answer_sv)
      end
    end

    describe "add cost" do
      let(:query) do
        %(
          {
            answer(
              state: "accepted"
              cost: #{cost}
              costReport: {
                en: \"#{cost_report[:en]}\",
                fi: \"#{cost_report[:fi]}\",
                sv: \"#{cost_report[:sv]}\"
              }
              executionPeriod: {
                en: \"#{execution_period[:en]}\",
                fi: \"#{execution_period[:fi]}\",
                sv: \"#{execution_period[:sv]}\"
              }
            )
            {
              id
              state
            }
          }
        )
      end
      let(:cost) { ::Faker::Number.between(from: 1, to: 100_000.0).round(2).to_f }
      let(:cost_report) do
        {
          en: ::Faker::Lorem.paragraph,
          fi: ::Faker::Lorem.paragraph,
          sv: ::Faker::Lorem.paragraph
        }
      end
      let(:execution_period) do
        {
          en: ::Faker::Lorem.paragraph,
          fi: ::Faker::Lorem.paragraph,
          sv: ::Faker::Lorem.paragraph
        }
      end

      it "changes proposal's cost" do
        expect(response["answer"]).to include("state" => "accepted")
        expect(response["answer"]).to include("id" => model.id.to_s)
        proposal = Decidim::Proposals::Proposal.find(model.id)
        expect(proposal.cost).to eq(cost)
        expect(proposal.cost_report["en"]).to eq(cost_report[:en])
        expect(proposal.cost_report["fi"]).to eq(cost_report[:fi])
        expect(proposal.cost_report["sv"]).to eq(cost_report[:sv])
        expect(proposal.execution_period["en"]).to eq(execution_period[:en])
        expect(proposal.execution_period["fi"]).to eq(execution_period[:fi])
        expect(proposal.execution_period["sv"]).to eq(execution_period[:sv])
      end
    end
  end
end

shared_examples "manage proposal classifications mutation examples" do
  context "when non admin user is logged in" do
    it "raises error" do
      expect { response }.to raise_error(Decidim::Apiext::ActionForbidden)
    end
  end
  context "when admin is logged in" do
    before do
      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(described_class).to receive(:current_user).and_return(user)
      # rubocop:enable RSpec/AnyInstance
    end

    it "changes proposals scope and category" do
      classification_response = response["updateClassifications"]
      expect(classification_response).to include("id" => model.id.to_s)
      expect(classification_response["scope"]).to include("id" => update_scope.id.to_s)
      expect(classification_response["category"]).to include("id" => update_category.id.to_s)
      
      updated_proposal = Decidim::Proposals::Proposal.find(model.id)
      expect(updated_proposal.category).to eq(update_category)
      expect(updated_proposal.scope).to eq(update_scope)
    end

    it "sends notification to the author" do
      expect(Decidim::EventsManager).to receive(:publish).with(
        hash_including(event: "decidim.events.proposals.proposal_update_scope")
      )
      expect(Decidim::EventsManager).to receive(:publish).with(
        hash_including(event: "decidim.events.proposals.proposal_update_category")
      )

      response
    end

    context "when category is not provided" do
      let(:query) do
        %(
          {
            updateClassifications(
              scopeId: #{update_scope&.id}
            ){
                id
                category {
                  id
                }
                scope {
                  id
                }
              }
          }
        )
      end

      it "does only updates scope" do
        expect(api_response).to include("id" => model.id.to_s)
        expect(api_response["scope"]).to include("id" => update_scope.id.to_s)
        expect(api_response["category"]).to include("id" => categories.first.id.to_s)
        
        updated_proposal = Decidim::Proposals::Proposal.find(model.id)
        expect(updated_proposal.category).to eq(categories.first)
        expect(updated_proposal.scope).to eq(update_scope)
      end

      it "only sends the notification to the author about scope change" do
        expect(Decidim::EventsManager).to receive(:publish).with(
          hash_including(event: "decidim.events.proposals.proposal_update_scope")
        )
        expect(Decidim::EventsManager).not_to receive(:publish).with(
          hash_including(event: "decidim.events.proposals.proposal_update_category")
        )

        response
      end
    end

    context "when the category does not belong the same space" do
      let!(:another_space) { create(:participatory_process, organization: model.organization) }
      let!(:update_category) { create(:category, participatory_space: another_space)}

      it "returns error" do
        expect { api_response }.to raise_error(StandardError, /Please select a category/)
      end
    end

    context "when scope is not provided" do
      let(:query) do
        %(
          {
            updateClassifications(
              categoryId: #{update_category&.id}
            ){
                id
                category {
                  id
                }
                scope {
                  id
                }
              }
          }
        )
      end

      it "does only updates category" do
        expect(api_response).to include("id" => model.id.to_s)
        expect(api_response["scope"]).to include("id" => scopes.first.id.to_s)
        expect(api_response["category"]).to include("id" => update_category.id.to_s)
        
        updated_proposal = Decidim::Proposals::Proposal.find(model.id)
        expect(updated_proposal.category).to eq(update_category)
        expect(updated_proposal.scope).to eq(scopes.first)
      end

      it "only sends the notification to the author about category change" do
        expect(Decidim::EventsManager).not_to receive(:publish).with(
          hash_including(event: "decidim.events.proposals.proposal_update_scope")
        )
        expect(Decidim::EventsManager).to receive(:publish).with(
          hash_including(event: "decidim.events.proposals.proposal_update_category")
        )

        response
      end
    end

    context "when the scope does not belong the same organization" do
      let!(:another_organization) { create(:organization) }
      let!(:update_scope) { create(:scope, organization: another_organization)}

      it "returns error" do
        expect { api_response }.to raise_error(StandardError, /Please select a scope/)
      end
    end
  end
end
