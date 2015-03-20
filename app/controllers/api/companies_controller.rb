class Api::CompaniesController < ApplicationController
  before_filter :authenticate_user_from_token!
  respond_to :json

  def index
    #if current_user.present?
      usercompany = UserCompany.where(:user_id => current_user.id).first
      @company = Company.find(usercompany.company_id)
    #end
  end
end