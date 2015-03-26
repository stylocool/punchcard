class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  protect_from_forgery with: :exception
  protect_from_forgery with: :null_session, :if => Proc.new { |c| c.request.format == 'application/json'}

  before_filter :authenticate_user_from_token!
  before_filter :initialize_user_company

  def authenticate_user_from_token!
    user_email = request.headers["X-API-EMAIL"].presence
    user_auth_token = request.headers["X-API-TOKEN"].presence
    user = user_email && User.find_by_email(user_email)

    if user && Devise.secure_compare(user.authentication_token, user_auth_token)
      sign_in(user, store: false)
    end
  end

  def initialize_user_company
    if current_user.present?
      usercompany = UserCompany.find_by_user_id(current_user.id)
      if usercompany.present?
        current_user.current_company = Company.find(usercompany.company_id)
      end
    end
  end

  def authenticate_active_admin_user!
    authenticate_user!
    if current_user.role.present?
      unless current_user.role?(:Administrator) || current_user.role?(:Root)
        flash.now[:alert => "You are not authorized to view this page"]
      end
    end
  end

  def access_denied(exception)
    redirect_to admin_root_path, :alert => exception.message
  end

end