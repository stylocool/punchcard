require 'rails_helper'

feature "Users" do
  scenario "can login" do
    visit user_session_path
    fill_in "Email", with: "admin@example.com"
    fill_in "Password", with: "password"
    click_on 'Login'
    expect(page).to have_text("Signed in successfully.")
  end

  scenario "can view all companies" do
    visit admin_companies_path
  end
end