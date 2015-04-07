ActiveAdmin.register Punchcard do
  permit_params :company_id, :project_id, :worker_id, :checkin_location, :checkin, :checkout_location, :checkout, :fine, :cancel_pay, :leave

  controller do

#    def index
#      index! do |format|

#        if current_user.role? :Root
#          @punchcards = Punchcard.all.page(params[:page])

#          @punchcards.each do |punchcard|
#            punchcard.work = PayrollWorkItem.new
#            punchcard.work.punchcard = punchcard
#            punchcard.work.calculate
#          end

#        else
#          if current_user.current_company.present?
#            @punchcards = Punchcard.where(:company_id => current_user.current_company.id).page(params[:page])

#            @punchcards.each do |punchcard|
#              punchcard.work = PayrollWorkItem.new
#              punchcard.work.punchcard = punchcard
#              punchcard.work.calculate
#            end

#          else
#            @punchcards = Punchcard.none
#          end
#        end
#        format.html
#      end
#    end

    def find_resource
      @punchcard = Punchcard.where(id: params[:id]).first

      if current_user.role? :Root || :Administrator
        @versions = @punchcard.versions
        @punchcard = @punchcard.versions[params[:version].to_i].reify if params[:version]
      end

      if current_user.role? :Root
        @punchcard
      else
        if current_user.current_company.present?
          if @punchcard.company_id == current_user.current_company.id
            @punchcard
          else
            :access_denied
          end
        else
          :access_denied
        end
      end
    end

    def map
      punchcard = Punchcard.find(params[:id])

      projectLocation = punchcard.project.location.split(',')
      @projectLat = projectLocation[0]
      @projectLng = projectLocation[1]

      checkinLocation = punchcard.checkin_location.split(',')
      @checkinLat = checkinLocation[0]
      @checkinLng = checkinLocation[1]

      checkoutLocation = punchcard.checkout_location.split(',')
      @checkoutLat = checkoutLocation[0]
      @checkoutLng = checkoutLocation[1]

      projectGeoLoc = Geokit::GeoLoc.new(lat:@projectLat,lng:@projectLng)
      checkinGeoLoc = Geokit::GeoLoc.new(lat:@checkinLat,lng:@checkinLng)
      checkoutGeoLoc = Geokit::GeoLoc.new(lat:@checkoutLat,lng:@checkoutLng)

      checkinDistance = checkinGeoLoc.distance_to(projectGeoLoc, :units => :kms)
      checkoutDistance = checkoutGeoLoc.distance_to(projectGeoLoc, :units => :kms)

      @projectTitle = "Project #{punchcard.project.name}"
      @checkinTitle = "Checkin @ #{punchcard.checkin} - #{checkinDistance.round(2)} km"
      @checkoutTitle = "Checkin @ #{punchcard.checkout} - #{checkoutDistance.round(2)} km"

    end
  end

  scope :all, :default => true
  scope :empty_checkin do |punchcards|
    punchcards.where('checkin is null')
  end
  scope :empty_checkout do |punchcards|
    punchcards.where('checkout is null')
  end

  index do

    selectable_column
    id_column
    column :company
    column :project
    column :worker
    column :checkin_location do |punchcard|
      if punchcard.checkin_location.present?
        projectLocation = punchcard.project.location.split(',')
        projectGeoLoc = Geokit::GeoLoc.new(lat:projectLocation[0],lng:projectLocation[1])

        checkinLocation = punchcard.checkin_location.split(',')
        checkinGeoLoc = Geokit::GeoLoc.new(lat:checkinLocation[0],lng:checkinLocation[1])
        checkinDistance = checkinGeoLoc.distance_to(projectGeoLoc, :units => :kms)

        company_setting = punchcard.company.company_setting

        if checkinDistance.to_i > company_setting.distance_check.to_i
          content_tag(:div, "#{checkinDistance.round(2)} km", style: "color:red")
        else
          content_tag(:div, "#{checkinDistance.round(2)} km")
        end
      end
    end
    column :checkin
    column :checkout_location do |punchcard|
      if punchcard.checkout_location.present?
        projectLocation = punchcard.project.location.split(',')
        projectGeoLoc = Geokit::GeoLoc.new(lat:projectLocation[0],lng:projectLocation[1])

        checkoutLocation = punchcard.checkout_location.split(',')
        checkoutGeoLoc = Geokit::GeoLoc.new(lat:checkoutLocation[0],lng:checkoutLocation[1])
        checkoutDistance = checkoutGeoLoc.distance_to(projectGeoLoc, :units => :kms)

        company_setting = punchcard.company.company_setting

        if checkoutDistance.to_i > company_setting.distance_check.to_i
          content_tag(:div, "#{checkoutDistance.round(2)} km", style: "color:red")
        else
          content_tag(:div, "#{checkoutDistance.round(2)} km")
        end
      end
    end
    column :checkout
    column :leave
    column :fine do |punchcard|
      "#{number_to_currency(punchcard.fine)}"
    end
    column :cancel_pay
    column 'Total/Normal/Overtime Hours', :total_hours do |punchcard|
      work = PayrollWorkItem.new
      work.punchcard = punchcard
      work.calculate
      "#{work.total_hours} / #{work.normal_work_hours} / #{work.overtime_work_hours}"
    end

    column :amount do |punchcard|
      work = PayrollWorkItem.new
      work.punchcard = punchcard
      work.calculate
      if work.amount < 0
        content_tag(:div, "#{number_to_currency(work.amount)}", style: "color:red")
      else
        content_tag(:div, "#{number_to_currency(work.amount)}")
      end
    end

    column :map do |punchcard|
      link_to 'View', "punchcards/map/#{punchcard.id}"
    end

    column :remarks do |punchcard|
      work = PayrollWorkItem.new
      work.punchcard = punchcard
      work.calculate
      content_tag(:div, "#{work.remarks}", style: "color:red")
    end

    actions
  end

  sidebar :history, :only => :show do
    if current_user.role? :Root || :Administrator
      render "layouts/version"
    end
  end

  member_action :history do
    if current_user.role? :Root || :Administrator
      @punchcard = Punchcard.find(params[:id])
      @versions = @punchcard.versions
      render "layouts/history"
    end
  end

  filter :company, as: :select, collection: proc {
                   if current_user.role? :Root
                     Company.all.map{|u| ["#{u.name}", u.id]}
                   #elsif current_user.role? :Administrator
                   else
                     usercompany = UserCompany.find_by_user_id(current_user.id)
                     if usercompany.present?
                       Company.all.where(:id => usercompany.company_id).map{|u| ["#{u.name}", u.id]}
                     else
                       Company.none
                     end
                   end
                 }
  filter :project, as: :select, collection: proc {
                     if current_user.role? :Root
                       Project.all.map{|u| ["#{u.name}", u.id]}
                     #elsif current_user.role? :Administrator
                     else
                       if current_user.current_company.present?
                         Project.all.where(:company_id => current_user.current_company.id).map{|u| ["#{u.name}", u.id]}
                       else
                         Project.none
                       end
                     end
                 }
  filter :worker, as: :select, collection: proc {
                  if current_user.role? :Root
                    Worker.all.map{|u| ["#{u.name}", u.id]}
                    #elsif current_user.role? :Administrator
                  else
                    if current_user.current_company.present?
                      Worker.all.where(:company_id => current_user.current_company.id).map{|u| ["#{u.name}", u.id]}
                    else
                      Worker.none
                    end
                  end
                }

  filter :checkin
  filter :checkout

  form do |f|
      f.inputs "Punchcard Details" do
      f.input :company, as: :select, include_blank: false, collection:
                          if current_user.role? :Root
                            Company.all.map{|u| ["#{u.name}", u.id]}
                          #elsif current_user.role? :Administrator
                          else
                            usercompany = UserCompany.find_by_user_id(current_user.id)
                            if usercompany.present?
                              Company.all.where(:id => usercompany.company_id).map{|u| ["#{u.name}", u.id]}
                            else
                              Company.none
                            end
                          end
      f.input :project, as: :select, include_blank: false, collection:
                          if current_user.role? :Root
                            Project.all.map{|u| ["#{u.name}", u.id]}
                          #elsif current_user.role? :Administrator
                          else
                            if current_user.current_company.present?
                              Project.all.where(:company_id => current_user.current_company.id).map{|u| ["#{u.name}", u.id]}
                            else
                              Project.none
                            end
                          end
      f.input :worker, as: :select, include_blank: false, collection:
                          if current_user.role? :Root
                           Worker.all.map{|u| ["#{u.name}", u.id]}
                          #elsif current_user.role? :Administrator
                          else
                            if current_user.current_company.present?
                              Worker.all.where(:company_id => current_user.current_company.id).map{|u| ["#{u.name}", u.id]}
                            else
                              Worker.none
                            end
                          end
      f.input :checkin_location
      f.input :checkin, as: :datepicker
      f.input :checkout_location
      f.input :checkout, as: :datepicker
      f.input :leave, as: :select, collection: { AmLeave:'Leave (AM)', PmLeave:'Leave (PM)', Leave:'Leave', MC:'MC' }
      f.input :fine, :as => :number
      f.input :cancel_pay
    end
    f.actions
  end

end