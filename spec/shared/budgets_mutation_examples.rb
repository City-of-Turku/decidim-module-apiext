# frozen_string_literal: true

shared_examples "create budget mutation examples" do
  it "creates the budget" do
    expect { response }.to change(Decidim::Budgets::Budget, :count).by(1)

    budget = Decidim::Budgets::Budget.last
    expect(response["createBudget"]).to eq("id" => budget.id.to_s)

    expect(budget.title).to match(attributes[:title].stringify_keys)
    expect(budget.description).to match(attributes[:description].stringify_keys)
    expect(budget.total_budget).to eq(attributes[:totalBudget])
    expect(budget.decidim_scope_id).to eq(scope.id)
    expect(budget.weight).to eq(attributes[:weight])
  end

  context "when scopeId is omitted" do
    let(:attributes) { super().except(:scopeId) }

    context "when the component has a configured scope" do
      let(:model) do
        create(
          :budgets_component,
          participatory_space:,
          settings: {
            scopes_enabled: true,
            scope_id: scope.id
          }
        )
      end

      it "uses the component scope" do
        expect(model.scope).to eq(scope)

        expect { response }
          .to change(Decidim::Budgets::Budget, :count).by(1)

        budget = Decidim::Budgets::Budget.last

        expect(budget.decidim_scope_id).to eq(scope.id)
        expect(response["createBudget"]["id"]).to eq(budget.id.to_s)
      end
    end

    context "when the component has no configured scope" do
      it "creates the budget without a scope" do
        expect(model.scope).to be_nil

        expect { response }
          .to change(Decidim::Budgets::Budget, :count).by(1)

        expect(Decidim::Budgets::Budget.last.decidim_scope_id).to be_nil
      end
    end
  end
end

shared_examples "update budget mutation examples" do
  it "updates the budget" do
    expect { response }.not_to change(Decidim::Budgets::Budget, :count)

    budget = Decidim::Budgets::Budget.order(:id).last
    expect(response["updateBudget"]).to eq("id" => budget.id.to_s)

    expect(budget.title).to match(attributes[:title].stringify_keys)
    expect(budget.description).to match(attributes[:description].stringify_keys)
    expect(budget.total_budget).to eq(attributes[:totalBudget])
    expect(budget.decidim_scope_id).to eq(scope.id)
    expect(budget.weight).to eq(attributes[:weight])
  end

  context "when scopeId is omitted" do
    let(:attributes) { super().except(:scopeId) }

    context "when the component has a configured scope" do
      let(:model) do
        create(
          :budgets_component,
          participatory_space:,
          settings: {
            scopes_enabled: true,
            scope_id: scope.id
          }
        )
      end

      it "falls back to the component scope" do
        expect(model.scope).to eq(scope)

        response

        expect(budget.reload.decidim_scope_id).to eq(scope.id)
      end
    end

    context "when the component has no configured scope" do
      it "updates the budget without assigning a scope" do
        expect(model.scope).to be_nil

        response

        expect(budget.reload.decidim_scope_id).to be_nil
      end
    end
  end
end
