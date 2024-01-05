# frozen_string_literal: true

shared_examples "create timeline entry mutation examples" do
  it "creates a new timeline entry" do
    expect { response }.to change(Decidim::Accountability::TimelineEntry, :count).by(1)

    expect(response["createTimelineEntry"]["id"]).to match(/[0-9]+/)

    model.reload
    timeline_entry = model.timeline_entries.first
    expect(timeline_entry.title).to eq(title)
    expect(timeline_entry.description).to eq(description)
    expect(timeline_entry.entry_date).to eq(entry_date)
  end
end

shared_examples "update timeline entry mutation examples" do
  it "updates the timeline entry" do
    expect { response }.not_to change(Decidim::Accountability::TimelineEntry, :count)

    expect(response["updateTimelineEntry"]["id"]).to eq(entry.id.to_s)

    entry.reload
    expect(entry.title).to include(title)
    expect(entry.description).to include(description)
    expect(entry.entry_date).to eq(entry_date)
  end
end

shared_examples "delete timeline entry mutation examples" do
  it "destroys the timeline entry" do
    expect { response }.to change(Decidim::Accountability::TimelineEntry, :count).by(-1)

    expect(response["deleteTimelineEntry"]["id"]).to match(entry.id.to_s)
  end
end
