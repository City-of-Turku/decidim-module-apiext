# frozen_string_literal: true

require "spec_helper"

describe "APICredentials" do
  let(:admin) { create(:admin) }
  let!(:organization) { create(:organization) }
  let!(:organization1) { create(:organization) }
  let(:dummy_token) { "token1234567890" }

  before do
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(Decidim::Apiext::TokenGenerator).to receive(:generate_token).and_return(dummy_token)
    # rubocop:enable RSpec/AnyInstance
    login_as admin, scope: :admin
    visit decidim_system.admins_path
  end

  it "API credentials index" do
    within "nav.main-nav" do
      expect(page).to have_link("API credentials", href: "/system/api_users")
      click_link_or_button "API credentials"
      li_element = find("li.active")
      within li_element do
        expect(page).to have_link("API credentials", href: "/system/api_users")
      end
    end
    expect(page).to have_current_path("/system/api_users")
    within "table.stack" do
      ths = find_all("th")
      expect(ths[0]).to have_content("Organization")
      expect(ths[1]).to have_content("Name")
      expect(ths[2]).to have_content("Key")
      expect(ths[3]).to have_content("Secret")
      expect(ths[4]).to have_content("Created at")
      expect(ths[5]).to have_content("Actions")
    end
  end

  context "with api_users" do
    let!(:set) { create_list(:api_user, 3, organization:) }
    let!(:set1) { create_list(:api_user, 4, organization: organization1) }

    before do
      visit decidim_system.api_users_path
    end

    it "shows all of the api_users" do
      api_users = Decidim::Apiext::ApiUser.all

      within "table.stack" do
        api_users.each do |user|
          tr = find("td", text: user.api_key).find(:xpath, "..")
          tds = tr.find_all("td")
          expect(tds.first).to have_content(user.organization.host)
          expect(tds[1]).to have_content(user.name)
          expect(tds[2]).to have_content(user.api_key)
          expect(tds.last).to have_link("Remove user")
          expect(tds.last).to have_link("Refresh secret")
        end
      end
      expect(page).to have_link("New API user")
    end

    it "revokes the token" do
      deleting_user = set.last
      expect(page).to have_content(deleting_user.api_key)
      within "table.stack" do
        delete_tr = find("td", text: deleting_user.api_key).find(:xpath, "..")
        within delete_tr do
          click_link_or_button "Remove user"
        end
      end
      expect(page).to have_content("Are you sure you want to remove this API user?")
      within "#confirm-modal" do
        click_link_or_button "OK"
      end
      expect(page).to have_content("API user successfully deleted.")
      expect(page).to have_current_path("/system/api_users")
      expect(Decidim::Apiext::ApiUser.count).to eq(6)
      expect(page).to have_no_content(deleting_user.api_key)
    end

    it "refreshes the token" do
      refreshing_user = set.last
      refreshing_tr = find("td", text: refreshing_user.api_key).find(:xpath, "..")

      within refreshing_tr do
        click_link_or_button "Refresh secret"
      end

      expect(page).to have_content("Are you sure you want to refresh the secret for this API user?")

      within "#confirm-modal" do
        click_link_or_button "OK"
      end

      expect(page).to have_content("Token refreshed successfully.")
      expect(page).to have_current_path("/system/api_users")
      expect(Decidim::Apiext::ApiUser.count).to eq(7)
      within refreshing_tr do
        expect(page).to have_button("Copy secret")
      end
      click_link_or_button("Copy secret")
      expect(page).to have_content("Copied")
    end

    it "creates new api user" do
      click_link_or_button "New API user"
      expect(page).to have_current_path("/system/api_users/new")
      expect(page).to have_content("Create new API user")
      expect(page).to have_content("Select your organization")
      click_link_or_button "Create"
      expect(page).to have_current_path("/system/api_users/new")
      select organization.host, from: "admin_organization"
      click_link_or_button "Create"
      expect(page).to have_current_path("/system/api_users/new")
      fill_in "Name", with: "Dummy name"
      within "select#admin_organization" do
        expect(page).to have_css("option", text: organization.host)
        expect(page).to have_css("option", text: organization.host)
      end
      click_link_or_button "Create"
      expect(page).to have_content("API user created successfully.")
      current_url = URI.parse(page.current_path)
      expect(current_url.path).to eq("/system/api_users")
      within "table.stack" do
        expect(page).to have_content("Dummy name")
        new_tr = find("td", text: "Dummy name").find(:xpath, "..")
        within new_tr do
          expect(page).to have_content(dummy_token)
          expect(page).to have_css("button[data-controller='clipboard-copy']", text: "Copy secret")
        end
      end
      click_link_or_button "Copy secret"
      expect(page).to have_no_link("Copy secret")
      expect(page).to have_content("Copied")
    end
  end
end
