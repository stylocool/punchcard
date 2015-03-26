#include Geokit::Geocoders

ActiveAdmin.register Project do

  permit_params :name, :location, :company_id

  controller do
    #def index
    #  index! do |format|
    #    if current_user.role? :Root
    #      @projects = Project.all.page(params[:page])
    #    else
    #      if current_user.current_company.present?
    #        @projects = Project.where(:company_id => current_user.current_company.id).page(params[:page])
    #      else
    #        @projects = Project.none
    #      end
    #    end
    #    format.html
    #  end
    #end

    def find_resource
      @project = Project.where(id: params[:id]).first!
      if current_user.role? :Root
        @project
      else
        if @project.company_id == current_user.current_company.id
          @project
        else
          :access_denied
        end
      end
    end
  end

  index do
    selectable_column
    id_column
    column :name
    column :location do |project|
      #projectLocation = project.location.split(',')
      #projectGeoLoc = Geokit::GeoLoc.new(lat:projectLocation[0],lng:projectLocation[1])

      #loc = Geokit::Geocoders::GoogleGeocoder.reverse_geocode projectGeoLoc

      link_to "View", "http://map.google.com/?q=#{project.location}"
    end
    column :company
    column :created_at
    actions
  end

  filter :name
  filter :location
  filter :company, as: :select, include_blank: false, collection: proc {
                   if current_user.role? :Root
                     Company.all.map{|u| ["#{u.name}", u.id]}
                   elsif current_user.role? :Administrator
                     usercompany = UserCompany.find_by_user_id(current_user.id)
                     if usercompany.present?
                       Company.all.where(:id => usercompany.company_id).map{|u| ["#{u.name}", u.id]}
                     else
                       Company.none
                     end
                   end
                 }

  form do |f|
      f.inputs "Project Details" do
      f.input :name
      f.input :location, label: 'Location (lat,lng). Use Google Map to find the coordinates.)'
      f.input :company, as: :select, include_blank: false, collection:
                          if current_user.role? :Root
                            Company.all.map{|u| ["#{u.name}", u.id]}
                          elsif current_user.role? :Administrator
                            usercompany = UserCompany.find_by_user_id(current_user.id)
                            if usercompany.present?
                              Company.all.where(:id => usercompany.company_id).map{|u| ["#{u.name}", u.id]}
                            else
                              Company.none
                            end
                          end
    end
    f.actions
  end
end