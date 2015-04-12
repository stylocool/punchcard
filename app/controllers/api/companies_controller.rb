class Api::CompaniesController < ApplicationController
  before_filter :authenticate_user_from_token!
  respond_to :json

  def user_for_paper_trail
    if current_user.present?
      current_user.id
    else
      email = request.headers["X-API-EMAIL"].presence
      user = User.find_by_email(email)
      if user.present?
        user.id
      end
    end
  end

  def index
    #if current_user.present?
      usercompany = UserCompany.where(:user_id => current_user.id).first
      @server_time = Time.now
      @company = Company.find(usercompany.company_id)
    #end
  end
end