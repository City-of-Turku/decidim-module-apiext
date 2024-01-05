# frozen_string_literal: true

shared_examples "query type for participant details" do
  it "returns details for the user" do
    expect(response["name"]).to eq(model.name)
    expect(response["email"]).to eq(model.email)
    expect(response["nickname"]).to eq(model.nickname)
  end
end
