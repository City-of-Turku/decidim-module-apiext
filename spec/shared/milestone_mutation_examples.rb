# frozen_string_literal: true

shared_examples "create milestonemutation examples" do
  it "creates a new timeline entry" do
    expect { response }.to change(Decidim::Accountability::Milestone, :count).by(1)

    expect(response["createMilestone"]["id"]).to match(/[0-9]+/)

    model.reload
    milestone = model.milestones.first
    expect(milestone.title).to eq(title)
    expect(milestone.description).to eq(description)
    expect(milestone.entry_date).to eq(entry_date)
  end
end

shared_examples "update milestonemutation examples" do
  it "updates the timeline entry" do
    expect { response }.not_to change(Decidim::Accountability::Milestone, :count)

    expect(response["updateMilestone"]["id"]).to eq(entry.id.to_s)

    entry.reload
    expect(entry.title).to include(title)
    expect(entry.description).to include(description)
    expect(entry.entry_date).to eq(entry_date)
  end
end

shared_examples "delete milestonemutation examples" do
  it "destroys the timeline entry" do
    expect { response }.to change(Decidim::Accountability::Milestone, :count).by(-1)

    expect(response["deleteMilestone"]["id"]).to match(entry.id.to_s)
  end
end
