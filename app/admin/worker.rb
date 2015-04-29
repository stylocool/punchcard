ActiveAdmin.register Worker do
  permit_params :name, :race, :gender, :nationality, :contact, :work_permit, :company_id, :worker_type, :trade, :basic_pay

  controller do
    def scoped_collection
      if current_user.role == 'Root'
        Worker.all.page(params[:page]).per(20)
      else
        if current_user.current_company.present?
          Worker.where(company_id: current_user.current_company.id).page(params[:page]).per(20)
        else
          Worker.none
        end
      end
    end

    def find_resource
      @worker = Worker.where(id: params[:id]).first!
      return @worker if current_user.role == 'Root'
      @worker.company_id == current_user.current_company.id ? @worker : :access_denied
    end
  end

  scope :all, default: true
  scope :race_chinese do |punchcards|
    punchcards.where(race: 'Chinese')
  end
  scope :race_indian do |punchcards|
    punchcards.where(race: 'Indian')
  end
  scope :race_malay do |punchcards|
    punchcards.where(race: 'Malay')
  end
  scope :race_others do |punchcards|
    punchcards.where(race: 'Others')
  end
  scope :type_accountant do |punchcards|
    punchcards.where(worker_type: 'Accountant')
  end
  scope :type_admin do |punchcards|
    punchcards.where(worker_type: 'Admin')
  end
  scope :type_drafter do |punchcards|
    punchcards.where(worker_type: 'Drafter')
  end
  scope :type_engineer do |punchcards|
    punchcards.where(worker_type: 'Engineer')
  end
  scope :type_manager do |punchcards|
    punchcards.where(worker_type: 'Manager')
  end
  scope :type_purchaser do |punchcards|
    punchcards.where(worker_type: 'Purchaser')
  end
  scope :type_qs do |punchcards|
    punchcards.where(worker_type: 'QS')
  end
  scope :type_supervisor do |punchcards|
    punchcards.where(worker_type: 'Supervisor')
  end
  scope :type_worker do |punchcards|
    punchcards.where(worker_type: 'Worker')
  end
  scope :trade_electrical do |punchcards|
    punchcards.where(trade: 'Electrical')
  end
  scope :trade_fire do |punchcards|
    punchcards.where(trade: 'Fire')
  end

  index do
    selectable_column
    id_column
    column :name do |worker|
      best_in_place worker, :name, as: :input, url: [:admin, worker]
    end
    column :race do |worker|
      best_in_place worker, :race, as: :select, url: [:admin, worker], collection: { Chinese: 'Chinese', Indian: 'Indian', Malay: 'Malay', Others: 'Others' }
    end
    column :gender do |worker|
      best_in_place worker, :gender, as: :select, url: [:admin, worker], collection: { Male: 'Male', Female: 'Female' }
    end
    column :nationality
    column :contact do |worker|
      best_in_place worker, :contact, as: :input, url: [:admin, worker]
    end
    column :work_permit do |worker|
      best_in_place worker, :work_permit, as: :input, url: [:admin, worker]
    end
    column :company
    column :worker_type do |worker|
      best_in_place worker, :worker_type, as: :select, url: [:admin, worker], collection: { Worker: 'Worker', Supervisor: 'Supervisor' }
    end
    column :trade
    column :basic_pay do |worker|
      "#{number_to_currency(worker.basic_pay)}"
    end
    column :created_at
    actions
  end

  filter :name
  filter :race, as: :select, include_blank: false, collection: { Chinese: 'Chinese', Indian: 'Indian', Malay: 'Malay', Others: 'Others' }
  filter :gender, as: :select, include_blank: false, collection: { Male: 'Male', Female: 'Female' }
  filter :nationality, as: :select, include_blank: false, collection: proc {
                        Worker.select(:nationality).uniq.map { |u| ["#{u.nationality}", "#{u.nationality}"] }
                     }
  filter :work_permit
  filter :company, as: :select, collection: proc {
                   if current_user.role == 'Root'
                     Company.all.map { |u| ["#{u.name}", u.id] }
                   elsif current_user.role == 'Administrator'
                     user_company = UserCompany.find_by_user_id(current_user.id)
                     user_company.present? ? Company.all.where(id: user_company.company_id).map { |u| ["#{u.name}", u.id] } : Company.none
                   end
                 }
  filter :worker_type, as: :select, collection: { Accountant: 'Accountant', Admin: 'Admin', Drafter: 'Drafter', Engineer: 'Engineer', Manager: 'Manager', Purchaser: 'Purchaser', QS: 'QS', Supervisor: 'Supervisor', Worker: 'Worker' }
  filter :trade, as: :select, collection: { Electrical: 'Electrical', Fire: 'Fire' }

  form do |f|
    f.inputs 'Worker Details' do
      f.input :name
      f.input :race, as: :select, include_blank: false, collection: { Chinese: 'Chinese', Indian: 'Indian', Malay: 'Malay', Others: 'Others' }
      f.input :gender, as: :select, include_blank: false, collection: { Male: 'Male', Female: 'Female' }
      f.input :nationality, as: :country, priority_countries: ['SG', 'MY', 'IN', 'ID']
      f.input :contact, as: :number
      f.input :work_permit
      f.input :company, as: :select, include_blank: false, collection:
                          if current_user.role == 'Root'
                            Company.all.map { |u| ["#{u.name}", u.id] }
                          elsif current_user.role == 'Administrator'
                            usercompany = UserCompany.find_by_user_id(current_user.id)
                            usercompany.present? ? Company.all.where(id: usercompany.company_id).map { |u| ["#{u.name}", u.id] } : Company.none
                          end
      f.input :worker_type, as: :select, include_blank: false, collection: { Worker: 'Worker', Supervisor: 'Supervisor', Manager: 'Manager', Engineer: 'Engineer', Admin: 'Admin', Purchaser: 'Purchaser', Drafter: 'Drafter', QS: 'QS', Accountant: 'Accountant' }
      f.input :trade, as: :select, include_blank: false, collection: { Fire: 'Fire', Electrical: 'Electrical' }
      f.input :basic_pay, as: :number
    end
    f.actions
  end
end
