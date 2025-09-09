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
end
