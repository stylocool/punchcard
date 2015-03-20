class Api::SessionsController < Devise::SessionsController
  skip_before_filter :authenticate_user!, :only => [:create, :new]
  skip_authorization_check only: [:create, :failure, :show_current_user, :options, :new]
  respond_to :json

  def new
    self.resource = resource_class.new(sign_in_params)
    clean_up_passwords(resource)
    respond_with(resource, serialize_options(resource))
  end

  def create
    respond_to do |format|
      format.html {
        super
      }
      format.json {

        resource = resource_from_credentials
        #build_resource
        return invalid_login_attempt unless resource

        if resource.valid_password?(params[:password])

          if (resource.authentication_token_expiry.present?)
            if (resource.authentication_token_expiry < Time.now)
              # expired
              resource.authentication_token = generate_authentication_token
              resource.authentication_token_expiry = 1.day.from_now
            end
          else
            resource.authentication_token = generate_authentication_token
            resource.authentication_token_expiry = 1.day.from_now
          end

          usercompany = UserCompany.where(:user_id => resource.id).first
          company = Company.find(usercompany.company_id)

          if company.license.present?
            if company.license.expired_at > Time.now
              #sign_in("user", resource)
              sign_in(resource, store: false)
              render :json => { user: { id: resource.id, email: resource.email, :auth_token => resource.authentication_token, :auth_token_expiry => resource.authentication_token_expiry } }, success: true, status: :created
            else
              company_license_expired
            end
          else
            company_license_invalid
          end
        else
          invalid_login_attempt
        end
      }
    end
  end

  def destroy
    respond_to do |format|
      format.html {
        super
      }
      format.json {
        user = User.find_by_authentication_token(request.headers['X-API-TOKEN'])
        if user
          user.reset_authentication_token!
          render :json => { :message => 'Session deleted.' }, :success => true, :status => 204
        else
          render :json => { :message => 'Invalid token.' }, :status => 404
        end
      }
    end
  end

  protected
  def invalid_login_attempt
    warden.custom_failure!
    render json: { success: false, message: 'Error with your login or password' }, status: 401
  end

  def company_license_expired
    warden.custom_failure!
    render json: { success: false, message: 'Company license expired! Please renew your license to continue.' }, status: 401
  end

  def company_license_invalid
    warden.custom_failure!
    render json: { success: false, message: 'You do not have a valid license to use this service. Please contact PunchCard.' }, status: 401
  end

  def resource_from_credentials
    data = { email: params[:email] }
    if res = resource_class.find_for_database_authentication(data)
      if res.valid_password?(params[:password])
        res
      end
    end
  end
end