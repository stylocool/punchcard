ActiveAdmin.register Punchcard do
  #active_admin_import headers_rewrites: { 'Company' => :company_id, 'Project' => :project_id,
  #                                        'Worker' => :worker_id, 'User' => :user_id,
  #                                        'Checkin location' => :checkin_location, 'Checkin' => :checkin, 'Checkout location' => :checkout_location, 'Checkout' => :checkout,
  #                                        'Leave' => :leave, 'Fine' => :fine, 'Cancel pay' => :cancel_pay },
  #                    before_batch_import: ->(importer) {
  #                      company_names = importer.values_at(:company_id)
  #                      companies = Company.where(name: company_names).pluck(:name, :id)
  #                      options = Hash[*companies.flatten]
  #                      importer.batch_replace(:company_id, options)
  #                      project_names = importer.values_at(:project_id)
  #                      projects = Project.where(name: project_names).pluck(:name, :id)
  #                      options = Hash[*projects.flatten]
  #                      importer.batch_replace(:project_id, options)
  #                      worker_names = importer.values_at(:worker_id)
  #                      workers = Worker.where(name: worker_names).pluck(:name, :id)
  #                      options = Hash[*workers.flatten]
  #                      importer.batch_replace(:worker_id, options)
  #                      user_names = importer.values_at(:user_id)
  #                      users   = User.where(email: user_names).pluck(:email, :id)
  #                      options = Hash[*users.flatten]
  #                      importer.batch_replace(:user_id, options)
  #                    },
  #                    validate: false,
  #                    resource_class: Punchcard,
  #                    template: 'import' ,
  #                    template_object: ActiveAdminImport::Model.new(
  #                        name: 'Punchcard',
  #                        force_encoding: :auto,
  #                        csv_options: { col_sep: ',', row_sep: nil, quote_char: nil }
  #                    )

  permit_params :company_id, :project_id, :worker_id, :checkin_location, :checkin, :checkout_location, :checkout, :fine, :cancel_pay, :leave

  controller do

    def scoped_collection
      if current_user.role == 'Root'
        Punchcard.all.page(params[:page]).per(20)
      else
        if current_user.current_company.present?
          Punchcard.where(company_id: current_user.current_company.id).page(params[:page]).per(20)
        else
          Punchcard.none
        end
      end
    end

    def find_resource
      @punchcard = Punchcard.find(params[:id])

      if current_user.role == 'Root' || current_user.role == 'Administrator'
        @versions = @punchcard.versions
        @punchcard = @punchcard.versions[params[:version].to_i].reify if params[:version]
      end

      return @punchcard if current_user.role == 'Root'
      if current_user.current_company.present?
        @punchcard.company_id == current_user.current_company.id ? @punchcard : :access_denied
      else
        :access_denied
      end
    end

    def map
      punchcard = Punchcard.find(params[:id])

      project_location = punchcard.project.location.split(',')
      @project_lat = project_location[0]
      @project_lng = project_location[1]
      project_geo_loc = Geokit::GeoLoc.new(lat: @project_lat, lng: @project_lng)
      @project_title = "Project #{punchcard.project.name}"

      if punchcard.checkin.present?
        checkin_location = punchcard.checkin_location.split(',')
        @checkin_lat = checkin_location[0]
        @checkin_lng = checkin_location[1]
        checkin_geo_loc = Geokit::GeoLoc.new(lat: @checkin_lat, lng: @checkin_lng)
        checkin_distance = checkin_geo_loc.distance_to(project_geo_loc, units: :kms)
        @checkin_title = "Checkin @ #{punchcard.checkin.strftime('%Y-%m-%d %H:%M:%S')} - #{checkin_distance.round(2)} km"
      else

      end

      if punchcard.checkout.present?
        checkout_location = punchcard.checkout_location.split(',')
        @checkout_lat = checkout_location[0]
        @checkout_lng = checkout_location[1]
        checkout_geo_loc = Geokit::GeoLoc.new(lat: @checkout_lat, lng: @checkout_lng)
        checkout_distance = checkout_geo_loc.distance_to(project_geo_loc, units: :kms)
        @checkout_title = "Checkout @ #{punchcard.checkout.strftime('%Y-%m-%d %H:%M:%S')} - #{checkout_distance.round(2)} km"
      else

      end

      #checkin_address = Geokit::Geocoders::GoogleGeocoder.reverse_geocode(checkin_geo_loc)
      #checkout_address = Geokit::Geocoders::GoogleGeocoder.reverse_geocode(checkout_geo_loc)

    end
  end

  scope :all, default: true
  scope :empty_checkin do |punchcards|
    punchcards.where('checkin is null')
  end
  scope :empty_checkout do |punchcards|
    punchcards.where('checkout is null')
  end
  scope :cancel_pay do |punchcards|
    punchcards.where('cancel_pay = true')
  end
  scope :fine do |punchcards|
    punchcards.where('fine > 0')
  end

  index do
    selectable_column
    id_column
    column :company
    column :project
    column :worker
    column 'Uploaded By', :user
    column :checkin_location do |punchcard|
      # calculate
      punchcard.calculate

      if punchcard.checkin_location.present?
        project_location = punchcard.project.location.split(',')
        project_geo_loc = Geokit::GeoLoc.new(lat: project_location[0], lng: project_location[1])
        checkin_location = punchcard.checkin_location.split(',')
        checkin_geo_loc = Geokit::GeoLoc.new(lat: checkin_location[0], lng: checkin_location[1])
        checkin_distance = checkin_geo_loc.distance_to(project_geo_loc, units: :kms)
        company_setting = punchcard.company.company_setting
        checkin_distance.to_i > company_setting.distance_check.to_i ?
          content_tag(:div, "#{checkin_distance.round(2)} km", style: 'color:red') :
          content_tag(:div, "#{checkin_distance.round(2)} km")
      end
    end
    column :checkin
    column :checkout_location do |punchcard|
      if punchcard.checkout_location.present?
        project_location = punchcard.project.location.split(',')
        project_geo_loc = Geokit::GeoLoc.new(lat: project_location[0], lng: project_location[1])
        checkout_location = punchcard.checkout_location.split(',')
        checkout_geo_loc = Geokit::GeoLoc.new(lat: checkout_location[0], lng: checkout_location[1])
        checkout_distance = checkout_geo_loc.distance_to(project_geo_loc, units: :kms)
        company_setting = punchcard.company.company_setting
        checkout_distance.to_i > company_setting.distance_check.to_i ?
          content_tag(:div, "#{checkout_distance.round(2)} km", style: 'color:red') :
          content_tag(:div, "#{checkout_distance.round(2)} km")
      end
    end
    column :checkout
    column :leave
    column :fine do |punchcard|
      "#{number_to_currency(punchcard.fine)}"
    end
    column :cancel_pay
    column 'Total/Normal/Overtime Minutes', :total_hours do |punchcard|
      # hourly
      #"#{punchcard.total_hours} / #{punchcard.normal_work_hours} / #{punchcard.overtime_work_hours}"
      # minutely
      "#{punchcard.total_work_minutes} / #{punchcard.normal_work_minutes} / #{punchcard.overtime_work_minutes}"
    end
    column :amount do |punchcard|
      # hourly
      #punchcard.amount < 0 ? content_tag(:div, "#{number_to_currency(punchcard.amount)}", style: 'color:red') : content_tag(:div, "#{number_to_currency(punchcard.amount)}")
      # minutely
      punchcard.amount_minutes < 0 ? content_tag(:div, "#{number_to_currency(punchcard.amount_minutes)}", style: 'color:red') : content_tag(:div, "#{number_to_currency(punchcard.amount_minutes)}")
    end
    column :map do |punchcard|
      link_to 'View', "punchcards/map/#{punchcard.id}"
    end
    column :changes do |punchcard|
      #if current_user.role? :Root || :Administrator
        link_to "#{punchcard.versions.length.to_i}", "#{admin_audit_trails_path}/item_type/Punchcard/item_id/#{punchcard.id}"
      #else
      #  "#{punchcard.versions.length.to_i}"
      #end
    end
    column :remarks do |punchcard|
      content_tag(:div, "#{punchcard.remarks}", style: 'color:red')
    end
    actions
  end

  csv do
    column :company do |punchcard|
      "#{punchcard.company.name}"
    end
    column :project do |punchcard|
      "#{punchcard.project.name}"
    end
    column :worker do |punchcard|
      "#{punchcard.worker.name}"
    end
    column :user do |punchcard|
      if punchcard.user.present?
        "#{punchcard.user.email}"
      end
    end
    column :checkin_location
    column :checkin_location_diff do |punchcard|
      # calculate
      punchcard.calculate

      if punchcard.checkin_location.present?
        project_location = punchcard.project.location.split(',')
        project_geo_loc = Geokit::GeoLoc.new(lat: project_location[0], lng: project_location[1])
        checkin_location = punchcard.checkin_location.split(',')
        checkin_geo_loc = Geokit::GeoLoc.new(lat: checkin_location[0], lng: checkin_location[1])
        checkin_distance = checkin_geo_loc.distance_to(project_geo_loc, units: :kms)
        company_setting = punchcard.company.company_setting
        checkin_distance.to_i > company_setting.distance_check.to_i ? "#{checkin_distance.round(2)} km" : "#{checkin_distance.round(2)} km"
      end
    end
    column :checkin
    column :checkout_location
    column :checkout_location_diff do |punchcard|
      if punchcard.checkout_location.present?
        project_location = punchcard.project.location.split(',')
        project_geo_loc = Geokit::GeoLoc.new(lat: project_location[0], lng: project_location[1])
        checkout_location = punchcard.checkout_location.split(',')
        checkout_geo_loc = Geokit::GeoLoc.new(lat: checkout_location[0], lng: checkout_location[1])
        checkout_distance = checkout_geo_loc.distance_to(project_geo_loc, units: :kms)
        company_setting = punchcard.company.company_setting
        checkout_distance.to_i > company_setting.distance_check.to_i ? "#{checkout_distance.round(2)} km" : "#{checkout_distance.round(2)} km"
      end
    end
    column :checkout
    column :leave
    column :fine
    column :cancel_pay
    column :total_work do |punchcard|
      "#{punchcard.total_work_minutes} mins (Total) / #{punchcard.normal_work_minutes} mins (Normal) / #{punchcard.overtime_work_minutes} mins (Overtime)"
    end
    column :amount do |punchcard|
      punchcard.amount_minutes < 0 ? "#{number_to_currency(punchcard.amount_minutes)}" : "#{number_to_currency(punchcard.amount_minutes)}"
    end
    column :remarks do |punchcard|
      "#{punchcard.remarks}"
    end
  end

  sidebar :version, only: :show do
    if current_user.role == 'Root' || current_user.role == 'Administrator'
      @punchcard = Punchcard.find(params[:id])
      #@versions = @punchcard.versions
      #@versions = PaperTrail::Version.where(item_id: params[:id], item_type: 'Punchcard').order('id desc')
      render 'layouts/version'
    end
  end

  filter :company, as: :select, collection: proc {
                    if current_user.role == 'Root'
                      Company.all.map { |u| ["#{u.name}", u.id] }
                    elsif current_user.role == 'Administrator'
                      user_company = UserCompany.find_by_user_id(current_user.id)
                      user_company.present? ? Company.all.where(id: user_company.company_id).map { |u| ["#{u.name}", u.id] } : Company.none
                    end
                 }
  filter :project, as: :select, collection: proc {
                    if current_user.role == 'Root'
                      Project.all.map { |u| ["#{u.name}", u.id] }
                    else
                     current_user.current_company.present? ? Project.all.where(company_id: current_user.current_company.id).map { |u| ["#{u.name}", u.id] } : Project.none
                    end
                 }
  filter :worker, as: :select, collection: proc {
                    if current_user.role == 'Root'
                      Worker.all.map { |u| ["#{u.name}", u.id] }
                    else
                      current_user.current_company.present? ? Worker.all.where(company_id: current_user.current_company.id).map { |u| ["#{u.name}", u.id] } : Worker.none
                    end
                }

  filter :checkin, as: :date_time_range
  filter :checkout, as: :date_time_range
  filter :leave, as: :select, collection: { AmLeave: 'Leave (AM)', PmLeave: 'Leave (PM)', Leave: 'Leave', MC: 'MC' }
  filter :cancel_pay
  filter :fine

  form do |f|
    f.inputs 'Punchcard Details' do
      f.input :company, as: :select, include_blank: false, collection:
                          if current_user.role == 'Root'
                            Company.all.map { |u| ["#{u.name}", u.id] }
                          elsif current_user.role == 'Administrator'
                            user_company = UserCompany.find_by_user_id(current_user.id)
                            user_company.present? ? Company.where(id: user_company.company_id).map { |u| ["#{u.name}", u.id] } : Company.none
                          end

      f.input :project, as: :select, include_blank: false, collection:
                          if current_user.role == 'Root'
                            Project.all.map { |u| ["#{u.name}", u.id] }
                          else
                            current_user.current_company.present? ? Project.where(company_id: current_user.current_company.id).map { |u| ["#{u.name}", u.id] } : Project.none
                          end

      f.input :worker, as: :select, include_blank: false, collection:
                         if current_user.role == 'Root'
                           Worker.all.map { |u| ["#{u.name}", u.id] }
                         else
                           current_user.current_company.present? ? Worker.where(company_id: current_user.current_company.id).map { |u| ["#{u.name}", u.id] } : Worker.none
                         end

      f.input :user, as: :select, include_blank: false, collection:
                         User.where(id: current_user.id).map { |u| ["#{u.email}", u.id] }

      f.input :checkin_location
      f.input :checkin, as: :datetime_picker
      f.input :checkout_location
      f.input :checkout, as: :datetime_picker
      f.input :leave, as: :select, collection: { AmLeave: 'Leave (AM)', PmLeave: 'Leave (PM)', Leave: 'Leave', MC: 'MC' }
      f.input :fine, as: :number
      f.input :cancel_pay
    end
    f.actions
  end
end
