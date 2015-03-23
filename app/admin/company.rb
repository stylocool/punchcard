ActiveAdmin.register Company do
  permit_params :name, :address, :email, :telephone, :total_workers, :logo

  after_save      :add_user_company
  before_destroy  :remove_user_company

  controller do
    #def index
    #  index! do |format|
    #    if current_user.role? :Root
    #      @companies = Company.all.page(params[:page])
    #    elsif current_user.role? :Administrator
    #      @companies = Company.all.where("id in (select company_id from user_companies where user_id = ?)", current_user.id).page(params[:page])
    #      if @companies.count > 0
    #        @companies
    #      else
    #        @companies = Company.none
    #      end
    #    end
    #    format.html
    #  end
    #end

    def find_resource
      @company = Company.find(params[:id])
      if current_user.role? :Root
        @company
        #elsif current_user.role? :Administrator
      else
        if current_user.current_company.present?
          if current_user.current_company.id == @company.id
            @company
          else
            :access_denied
          end
        else
          :access_denied
        end
      end
    end

    def add_user_company(company)
      current_user.current_company = company
      usercompany = UserCompany.new(company_id: company.id, user_id: current_user.id)
      usercompany.save
    end

    def remove_user_company(company)
      UserCompany.where(:company_id => company.id).delete_all
      return true
    end

    def get_params
      params.require(:company).permit(:name, :address, :email, :telephone, :total_workers)
    end
  end


  index do
    selectable_column
    id_column
    column :name
    column :address
    column :email
    column :telephone
    column :total_workers
    column 'Logo', :photo do |company|
      image_tag(company.logo.url(:thumb), :height => '100')
    end
    column :created_at
    actions
  end

  filter :address
  filter :created_at
  filter :email
  filter :name
  #filter :status

  form multipart: true do |f|
      f.inputs "Company Details" do
      f.input :name
      f.input :address
      f.input :email
      f.input :telephone, :as => :number
      f.input :total_workers, :as => :number
      f.input :logo, :required => false
      # can only select current user for all types of users
      #f.input :user, as: :select, collection: User.all.where(:id => current_user.id).map{|u| ["#{u.email}", u.id]}, include_blank: false
    end
    f.actions
  end

end
