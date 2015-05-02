ActiveAdmin.register Project do
  permit_params :name, :location, :company_id

  controller do

    def scoped_collection
      if current_user.role == 'Root'
        Project.all.page(params[:page]).per(20)
      else
        if current_user.current_company.present?
          Project.where(company_id: current_user.current_company.id).page(params[:page]).per(20)
        else
          Project.none
        end
      end
    end

    def find_resource
      @project = Project.find(params[:id])
      return @project if current_user.role == 'Root'
      if current_user.current_company.present?
        @project.company_id == current_user.current_company.id ? @project : :access_denied
      else
        :access_denied
      end
    end
  end

  index do
    selectable_column
    id_column
    column :name do |project|
      best_in_place project, :name, as: :input, url: [:admin, project]
    end
    column :location do |project|
      link_to 'View', "http://map.google.com/?q=#{project.location}"
    end
    column :company
    column :created_at
    actions
  end

  filter :name
  filter :location
  filter :company, as: :select, include_blank: false, collection: proc {
                   if current_user.role == 'Root'
                     Company.all.map { |u| ["#{u.name}", u.id] }
                   elsif current_user.role == 'Administrator'
                     user_company = UserCompany.find_by_user_id(current_user.id)
                     user_company.present? ? Company.all.where(id: user_company.company_id).map { |u| ["#{u.name}", u.id] } : Company.none
                   end
                 }

  form do |f|
    f.inputs 'Project Details' do
      f.input :name
      f.input :location, label: 'Location (lat,lng)', hint: f.project.location.present? ? link_to('View', "http://map.google.com/?q=#{f.project.location}") : link_to('Check', 'http://map.google.com')
      f.input :company, as: :select, include_blank: false, collection:
                          if current_user.role == 'Root'
                            Company.all.map { |u| ["#{u.name}", u.id] }
                          elsif current_user.role == 'Administrator'
                            user_company = UserCompany.find_by_user_id(current_user.id)
                            user_company.present? ? Company.all.where(id: user_company.company_id).map { |u| ["#{u.name}", u.id] } : Company.none
                          end
    end
    f.actions
  end
end
