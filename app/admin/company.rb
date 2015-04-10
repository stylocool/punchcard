ActiveAdmin.register Company do
  permit_params :name, :address, :email, :telephone, :total_workers, :logo, :_destroy

  after_save :add_user_company
  before_destroy :remove_user_company
  after_destroy :remove_current_company

  controller do
    def find_resource
      @company = Company.find(params[:id])
      return @company if current_user.role? :Root
      if current_user.current_company.present?
        return @company if current_user.current_company.id == @company.id
        :access_denied
      else
        :access_denied
      end
    end

    def add_user_company(company)
      begin
        exist = UserCompany.find(company_id: company.id, user_id: current_user.id)
      rescue ActiveRecord::RecordNotFound
        exist = nil
      end

      return if exist.present?
      current_user.current_company = company
      user_company = UserCompany.new(company_id: company.id, user_id: current_user.id)
      user_company.save
    end

    def remove_user_company(company)
      UserCompany.where(company_id: company.id).delete_all
    end

    def remove_current_company
      current_user.current_company = nil
    end
  end

  index do
    selectable_column
    id_column
    column :name do |company|
      best_in_place company, :name, type: :input, path: [:admin, company]
    end
    column :address do |company|
      best_in_place company, :address, type: :textarea, path: [:admin, company]
    end
    column :email do |company|
      best_in_place company, :email, type: :input, path: [:admin, company]
    end
    column :telephone do |company|
      best_in_place company, :telephone, type: :input, path: [:admin, company]
    end
    column :total_workers do |company|
      best_in_place company, :total_workers, type: :input, path: [:admin, company]
    end
    column 'Logo', :photo do |company|
      image_tag(company.logo.url(:thumb), height: '100')
    end
    column :created_at
    actions
  end

  filter :address
  filter :created_at
  filter :email
  filter :name

  form multipart: true do |f|
    f.inputs 'Company Details' do
      f.input :name
      f.input :address
      f.input :email
      f.input :telephone, as: :number
      f.input :total_workers, as: :number
      f.input :logo, required: false, hint: image_tag(f.company.logo.url(:thumb))
    end
    f.actions
  end
end
