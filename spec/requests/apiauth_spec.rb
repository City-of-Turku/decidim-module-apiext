# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Api authentication", type: :request do
  let(:sign_in_path) { "/api/sign_in" }
  let(:sign_out_path) { "/api/sign_out" }

  let(:organization) { create(:organization) }
  let(:key) { "dummykey123456" }
  let(:secret) { "decidim123456789" }
  let!(:api_user) { create(:api_user, organization: organization, api_key: key, api_secret: secret) }
  let(:params) do
    {
      api_user: {
        key: key,
        secret: secret
      }
    }
  end
  let(:hacker_key) { "fakekey123456" }
  let(:invalid_params) do
    {
      api_user: {
        key: hacker_key,
        secret: "incorrectsecret"
      }
    }
  end
  let(:query) { "{session { user { id nickname } } }" }

  before do
    host! organization.host
  end

  it "signs in" do
    post sign_in_path, params: params
    expect(response.headers["Authorization"]).to be_present
    expect(response.body["jwt_token"]).to be_present
    parsed_response_body = JSON.parse(response.body)
    expect(response.headers["Authorization"].split[1]).to eq(parsed_response_body["jwt_token"])
  end

  it "renders resource when invalid credentials" do
    post sign_in_path, params: invalid_params

    parsed_response_body = JSON.parse(response.body)
    expect(parsed_response_body["api_key"]).to eq(hacker_key)
    expect(parsed_response_body["jwt_token"]).not_to be_present
  end

  it "signs out" do
    post sign_in_path, params: params
    expect(response).to have_http_status(:ok)
    authorzation = response.headers["Authorization"]
    orginal_count = Decidim::Apiext::JwtBlacklist.count
    delete sign_out_path, params: {}, headers: { HTTP_AUTHORIZATION: authorzation }
    expect(Decidim::Apiext::JwtBlacklist.count).to eq(orginal_count + 1)
  end

  context "when signed in" do
    before do
      post sign_in_path, params: params
    end

    it "can use token to post to api" do
      authorzation = response.headers["Authorization"]
      post "/api", params: { query: query }, headers: { HTTP_AUTHORIZATION: authorzation }
      parsed_response = JSON.parse(response.body)["data"]
      expect(parsed_response["session"]["user"]["id"].to_i).to eq(api_user.id)
      expect(parsed_response["session"]["user"]["nickname"]).to eq(api_user.nickname.prepend("@"))
    end
  end
end
