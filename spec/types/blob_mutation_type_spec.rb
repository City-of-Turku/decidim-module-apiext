# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Apifiles
    describe BlobMutationType do
      include_context "with a graphql class type"

      let(:model) do
        ActiveStorage::Blob.create_and_upload!(
          io: File.open(Decidim::Dev.asset("city.jpeg")),
          filename: "city.jpeg",
          content_type: "image/jpeg"
        )
      end

      context "with an api user" do
        let!(:current_user) { create(:api_user, organization: current_organization) }

        describe "id" do
          let(:query) { "{ id }" }

          it "returns the id" do
            expect(response).to include("id" => model.id.to_s)
          end
        end

        describe "delete" do
          let(:query) { "{ delete { id } }" }

          # Make sure the model is created before the test
          before { model }

          it "deletes the blob and returns the details" do
            expect do
              expect(response).to include("delete" => { "id" => model.id.to_s })
            end.to change(ActiveStorage::Blob, :count).by(-1)

            expect(ActiveStorage::Blob.find_by(id: model.id)).to be_nil
          end
        end
      end
    end
  end
end
