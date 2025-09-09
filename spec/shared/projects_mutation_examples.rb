# frozen_string_literal: true

shared_examples "update project mutation examples" do
  it "updates the project" do
    expect { response }.not_to change(Decidim::Budgets::Project, :count)

    expect(response["updateProject"]).to eq("id" => project.id.to_s)
    project.reload

    expect(project.title["en"]).to match(attributes[:title][:en])
    expect(project.description["en"]).to match(attributes[:description][:en])
    expect(project.budget_amount).to eq(attributes[:budgetAmount])
    expect(project.address).to eq(attributes[:location][:address])
    expect(project.latitude).to eq(attributes[:location][:latitude])
    expect(project.longitude).to eq(attributes[:location][:longitude])
    expect(project.category.id).to eq(category.id)
    expect(project.scope.id).to eq(scope.id)
    expect(project.linked_resources(:proposals, "included_proposals").map(&:id)).to match_array(proposals.map(&:id))
  end
end

shared_examples "create project mutation examples" do
  it "creates the project" do
    expect { response }.to change(Decidim::Budgets::Project, :count).by(1)

    project = Decidim::Budgets::Project.order(:id).last
    expect(response["createProject"]).to eq("id" => project.id.to_s)

    expect(project.title).to match(attributes[:title].stringify_keys)
    expect(project.description).to match(attributes[:description].stringify_keys)
    expect(project.budget_amount).to eq(attributes[:budgetAmount])
    expect(project.address).to eq(attributes[:location][:address])
    expect(project.latitude).to eq(attributes[:location][:latitude])
    expect(project.longitude).to eq(attributes[:location][:longitude])
    expect(project.category.id).to eq(category.id)
    expect(project.scope.id).to eq(scope.id)
    expect(project.linked_resources(:proposals, "included_proposals").map(&:id)).to match_array(proposals.map(&:id))
  end
end
