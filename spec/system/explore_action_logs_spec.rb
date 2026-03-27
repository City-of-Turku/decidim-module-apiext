# frozen_string_literal: true

require "spec_helper"

describe "ActionLogs" do
  let(:organization) { create(:organization) }

  let!(:user) { create(:user, :admin, :confirmed, name: "Mike", nickname: "mikey", email: "mike@example.org", organization:) }
  let!(:api_user) { create(:api_user, name: "Joe", nickname: "joeapi", email: "joe@example.org", organization:) }
  let!(:proposal) { create(:proposal) }

  context "when user public" do
    before do
      create_action_logs

      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin.root_path
      click_on "Admin activity log"
    end

    it "displays logs' author names correctly" do
      expect(page).to have_content("Admin log")

      within ".logs.table" do
        expect(page).to have_css("div.logs__log", count: 2)

        expect(page).to have_css("span.logs__log__author", text: api_user.name)
        expect(page).to have_css("a.logs__log__author", text: user.name)
      end
    end
  end

  context "when user private" do
    before do
      create_action_logs
      allow(Decidim).to receive(:module_installed?) do |module_name|
        module_name == :privacy
      end

      switch_to_host(organization.host)
      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(Decidim::User).to receive(:public?).and_return(false)
      # rubocop:enable RSpec/AnyInstance
      login_as user, scope: :user
      visit decidim_admin.root_path
      click_on "Admin activity log"
    end

    it "displays log's author name correctly" do
      within ".logs.table" do
        expect(page).to have_css("div.logs__log", count: 2)

        expect(page).to have_css("span.logs__log__author", text: api_user.name)
        expect(page).to have_css("span.logs__log__author", text: user.name)
      end
    end
  end

  context "when user anonymous" do
    before do
      create_action_logs
      allow(Decidim).to receive(:module_installed?) do |module_name|
        module_name == :privacy
      end

      switch_to_host(organization.host)
      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(Decidim::User).to receive(:public?).and_return(true)
      allow_any_instance_of(Decidim::User).to receive(:anonymous?).and_return(true)
      # rubocop:enable RSpec/AnyInstance
      login_as user, scope: :user
      visit decidim_admin.root_path
      click_on "Admin activity log"
    end

    it "displays log's author name correctly" do
      within ".logs.table" do
        expect(page).to have_css("div.logs__log", count: 2)

        expect(page).to have_css("span.logs__log__author", text: api_user.name)
        expect(page).to have_css("span.logs__log__author", text: user.name)
      end
    end
  end

  context "when filtering" do
    before do
      create_action_logs

      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin.root_path
      click_on "Admin activity log"
    end

    context "and there are no matching logs" do
      it "shows the correct message" do
        within ".filters__section" do
          fill_in(:q_user_searchable_cont, with: "mickey mouse")
          find("*[type=submit]").click
        end

        expect(page).to have_content("There are no logs with the provided search filters. Try to change them and retry.")
      end
    end

    context "and searching api user with nickname" do
      it "shows the correct action log" do
        within ".filters__section" do
          fill_in(:q_user_searchable_cont, with: "joeapi")
          find("*[type=submit]").click
        end

        within ".logs.table" do
          expect(page).to have_css("div.logs__log", count: 1)

          expect(page).to have_css("span.logs__log__author", text: api_user.name)
          expect(page).to have_no_css("span.logs__log__author", text: user.name)
        end
      end
    end

    context "and searching user with name" do
      it "shows the correct action log" do
        within ".filters__section" do
          fill_in(:q_user_searchable_cont, with: "Mike")
          find("*[type=submit]").click
        end

        within ".logs.table" do
          expect(page).to have_css("div.logs__log", count: 1)

          expect(page).to have_no_css("span.logs__log__author", text: api_user.name)
          expect(page).to have_css("a.logs__log__author", text: user.name)
        end
      end
    end

    context "and searching user with email" do
      it "shows the correct action log" do
        within ".filters__section" do
          fill_in(:q_user_searchable_cont, with: "mike@example.org")
          find("*[type=submit]").click
        end

        within ".logs.table" do
          expect(page).to have_css("div.logs__log", count: 1)

          expect(page).to have_no_css("span.logs__log__author", text: api_user.name)
          expect(page).to have_css("a.logs__log__author", text: user.name)
        end
      end
    end
  end
end

def create_action_logs
  Decidim::ActionLog.create!(
    decidim_organization_id: organization.id,
    user_id: user.id,
    resource_type: "Decidim::Proposals::Proposal",
    resource_id: proposal.id,
    action: "update",
    extra:
      { user:
          { ip: "::2", name: user.name, nickname: user.nickname },
        resource:
          { title:
            { fi: proposal.title["fi"] } },
        component: {},
        participatory_space: {} },
    visibility: "admin-only",
    user_type: "Decidim::User"
  )

  Decidim::ActionLog.create!(
    decidim_organization_id: organization.id,
    user_id: api_user.id,
    resource_type: "Decidim::Proposals::Proposal",
    resource_id: proposal.id,
    action: "update",
    extra:
      { user:
          { ip: "::2", name: api_user.name, nickname: api_user.nickname },
        resource:
          { title:
            { fi: proposal.title["fi"] } },
        component: {},
        participatory_space: {} },
    visibility: "admin-only",
    user_type: "Decidim::Apiext::ApiUser"
  )
end
