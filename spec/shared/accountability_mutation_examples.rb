# frozen_string_literal: true

shared_context "when the user does not have permissions" do
  let!(:current_user) { create(:user, :confirmed, organization: current_organization) }

  it "throws exception" do
    expect { response }.to raise_error(Decidim::Apiext::ActionForbidden)
  end
end

shared_context "with accountability graphql mutation" do
  def convert_value(value)
    values = value.map do |k, v|
      val = if v.is_a?(Hash)
              convert_value(v)
            else
              v.to_json
            end

      %(#{k}: #{val})
    end.join(", ")

    "{ #{values} }"
  end
end

shared_examples "create result mutation examples" do
  # it_behaves_like "when the user does not have permissions"

  it "creates a new result" do
    expect { response }.to change(Decidim::Accountability::Result, :count).by(1)

    expect(response["createResult"]["id"]).to match(/[0-9]+/)

    result = Decidim::Accountability::Result.last
    expect(result.title).to eq(title.stringify_keys)
    expect(result.description).to eq(description.stringify_keys)
    expect(result.start_date).to eq(Date.parse(start_date))
    expect(result.end_date).to eq(Date.parse(end_date))
    expect(result.progress).to eq(progress)
    expect(result.decidim_scope_id).to eq(scope.id)
    expect(result.status).to eq(status)
    expect(result.parent_id).to eq(parent_id)
    expect(result.linked_resources(:proposals, "included_proposals")).to match_array(proposals)
    expect(result.linked_resources(:projects, "included_projects")).to match_array(projects)
  end
end

shared_examples "update result mutation examples" do
  it "updates the result" do
    expect { response }.not_to change(Decidim::Accountability::Result, :count)

    expect(response["updateResult"]["id"]).to eq(result.id.to_s)

    result.reload
    expect(result.title).to eq(title.stringify_keys)
    expect(result.description).to eq(description.stringify_keys)
    expect(result.start_date).to eq(Date.parse(start_date))
    expect(result.end_date).to eq(Date.parse(end_date))
    expect(result.progress).to eq(progress)
    expect(result.decidim_scope_id).to eq(scope.id)
    expect(result.status).to eq(status)
    expect(result.parent_id).to eq(parent_id)
    expect(result.linked_resources(:proposals, "included_proposals")).to match_array(proposals)
    expect(result.linked_resources(:projects, "included_projects")).to match_array(projects)
  end
end

shared_examples "destroy result mutation examples" do
  it "destroys the timeline entry" do
    expect { response }.to change(Decidim::Accountability::Result, :count).by(-1)

    expect(response["deleteResult"]["id"]).to match(result.id.to_s)
  end
end
