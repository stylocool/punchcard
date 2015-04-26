ActiveAdmin.register CompanySetting do
  permit_params :name, :overtime_rate, :working_hours, :lunch_hour, :dinner_hour, :distance_check, :company_id

  controller do

    def scoped_collection
      if current_user.role == 'Root'
        CompanySetting.all.page(params[:page]).per(20)
      else
        if current_user.current_company.present? && current_user.current_company.company_setting.present?
          CompanySetting.where(id: current_user.current_company.company_setting.id).page(params[:page]).per(20)
        else
          CompanySetting.none
        end
      end
    end

    def find_resource
      @company_setting = CompanySetting.find(params[:id])
      return @company_setting if current_user.role? :Root
      if current_user.current_company.present?
        @company_setting.company_id == current_user.current_company.id ? @company_setting : :access_denied
      else
        :access_denied
      end
    end
  end

  index do
    selectable_column
    id_column
    column 'Working Hours/Day', :working_hours
    column :overtime_rate
    column :lunch_hour
    column :dinner_hour
    column :distance_check do |setting|
      "#{setting.distance_check} km"
    end
    column :company
    column :created_at
    actions
  end

  form do |f|
    f.inputs 'Company Settings Details' do
      f.input :name
      f.input :working_hours, label: 'Working Hours/Day'
      f.input :overtime_rate, label: 'Overtime hourly rate (x times of daily hourly rate)'
      f.input :lunch_hour, label: '1 hr lunch reduction if start work before 11am'
      f.input :dinner_hour, label: '1 hr dinner reduction if stop work after 10pm'
      f.input :distance_check, label: 'Distance check in km from project location'
      f.input :company, as: :select, include_blank: false, collection:
                            if current_user.role == 'Root'
                              Company.all.map { |u| ["#{u.name}", u.id] }
                            elsif current_user.role == 'Administrator'
                              usercompany = UserCompany.find_by_user_id(current_user.id)
                              if usercompany.present?
                                Company.all.where(id: usercompany.company_id).map { |u| ["#{u.name}", u.id] }
                              else
                                Company.none
                              end
                            end
    end
    f.actions
  end
end
