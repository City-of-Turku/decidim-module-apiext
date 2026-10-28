# frozen_string_literal: true

shared_examples "manage proposal mutation examples" do
  context "when non admin user is logged in" do
    describe "try to answer to proposal" do
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
      it "changes proposal's state" do
        expect(response["answer"]).to include(
          "id" => model.id.to_s,
          "state" => state
        )

        answer = model.reload.answer

        expect(answer["en"]).to eq(answer_en)
        expect(answer["fi"]).to eq(answer_fi)
        expect(answer["sv"]).to eq(answer_sv)
      end

      it "persists the answer content" do
        response

        expect(model.reload.answer).to include(
          "en" => answer_en,
          "fi" => answer_fi,
          "sv" => answer_sv
        )
      end
    end

    describe "add cost" do
      let(:cost) { Faker::Number.between(from: 1, to: 100_000.0).round(2).to_f }

      let(:cost_report) do
        {
          en: Faker::Lorem.paragraph,
          fi: Faker::Lorem.paragraph,
          sv: Faker::Lorem.paragraph
        }
      end

      let(:execution_period) do
        {
          en: Faker::Lorem.paragraph,
          fi: Faker::Lorem.paragraph,
          sv: Faker::Lorem.paragraph
        }
      end

      let(:variables) do
        super().deep_merge(
          input: {
            attributes: {
              state: "accepted",
              cost:,
              costReport: cost_report,
              executionPeriod: execution_period
            }
          }
        )
      end

      it "changes proposal's cost" do
        expect(response["answer"]).to include(
          "id" => model.id.to_s,
          "state" => "accepted"
        )

        proposal = model.reload

        expect(proposal.cost).to eq(cost)

        expect(proposal.cost_report).to include(
          "en" => cost_report[:en],
          "fi" => cost_report[:fi],
          "sv" => cost_report[:sv]
        )

        expect(proposal.execution_period).to include(
          "en" => execution_period[:en],
          "fi" => execution_period[:fi],
          "sv" => execution_period[:sv]
        )
      end
    end
  end
end
