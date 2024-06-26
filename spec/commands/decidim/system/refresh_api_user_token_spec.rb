# frozen_string_literal: true

require "spec_helper"

module Decidim
  module System
    describe RefreshApiUserToken do
      subject { described_class.new(api_user, admin) }

      let(:command) { subject.call }
      let(:api_user) { create(:api_user) }
      let(:organization) { create :organization }
      let(:admin) { create :admin }
      let(:valid) { true }
      let(:name) { "Dummy name" }
      let(:dummy_token) { "Dummy token" }

      before do
        allow(::Decidim::Apiext::TokenGenerator).to receive(:generate_token).twice.and_return(dummy_token)
      end

      context "when no admin" do
        let(:admin) { nil }

        it "broadcasts invalid" do
          expect { command }.to broadcast(:invalid)
        end
      end

      context "when no api_user" do
        let(:api_user) { nil }

        it "broadcasts invalid" do
          expect { command }.to broadcast(:invalid)
        end
      end

      it "broadcasts :ok with the generated token" do
        expect { command }.to broadcast(:ok) do |event_args|
          user, token = event_args
          expect(user).to eq(api_user)
          expect(token).to eq(dummy_token)
        end
      end
    end
  end
end
