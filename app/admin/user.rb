ActiveAdmin.register User do
  config.clear_sidebar_sections!

  permit_params :email, :password, :password_confirmation, :role

  before_create :company_exist
  after_save :add_user_company
  before_destroy :remove_user_company

  controller do
    def index
      index! do |format|
        if current_user.role? :Root
          @users = User.all.page(params[:page])
        elsif current_user.role? :Administrator
          current_user.current_company.present? ? @users = User.where('id in (select user_id from user_companies where company_id = ?)', current_user.current_company.id).page(params[:page]) : @users = User.where(id: current_user.id).page(params[:page])
        end
        format.html
      end
    end

    def find_resource
      @user = User.find(params[:id])
      return @user if current_user.role? :Root
      return @user if current_user.id == @user.id
      if @user.role? :User
        if current_user.current_company.present?
          user_companies = UserCompany.where(company_id: current_user.current_company.id)
          found = false
          user_companies.each do |uc|
            if uc.user_id == @user.id
              found = true
              break
            end
          end
          found ? @user : :access_denied
        else
          :access_denied
        end
      else
        :access_denied
      end
    end

    def company_exist(company)
      return if current_user.role != :Administrator
      return if current_user.current_company.present?
      flash.now[alert: 'Please create a company before adding new users']
    end

    def add_user_company(user)
      return if current_user.role != :Administrator
      user_company = UserCompany.new(company_id: current_user.current_company.id, user_id: user.id)
      user_company.save
    end

    def remove_user_company(user)
      # cannot delete itself
      if user.id == current_user.id
        logger.debug('Cannot delete yourself')
        flash.now[alert: 'Cannot delete itself']
        return false
      else
        if user.role?(:Root) || user.role?(:Administrator)
          # delete company will cascade delete to all e.g. company_setting, project, etc
          user_companies = UserCompany.where(user_id: user.id)
          if user_companies.count > 0
            user_companies.each do |uc|
              Company.find(uc.company_id).delete
            end
          end
        end

        UserCompany.where(user_id: user.id).delete_all
        return true
      end
    end
  end

  index do
    selectable_column
    id_column
    column :email
    column :current_sign_in_at
    column :sign_in_count
    column :role
    column :authentication_token
    column :authentication_token_expiry
    column :created_at
    actions
  end

  form do |f|
    f.inputs 'Admin Details' do
      f.input :email
      f.input :password
      f.input :password_confirmation
      if current_user.role? :Root
        f.input :role, as: :radio, collection: { Root: 'Root', Administrator: 'Administrator' }
      elsif current_user.role? :Administrator
        f.input :role, as: :radio, collection: { Administrator: 'Administrator', User: 'User' }
      end
    end
    f.actions
  end
end
