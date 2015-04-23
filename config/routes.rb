Rails.application.routes.draw do
  devise_for :users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  root to: "admin/dashboard#index"

  namespace :api, defaults: {format: 'json'} do
    devise_for :users, path: '', path_names: {sign_in: "login", sign_out: "logout"}

    resources :companies
    resources :punchcards
    resources :workers

    # additional methods
    get 'workers/work_permit/:id' => 'workers#show_by_work_permit'
  end

  namespace :admin do
    # payrolls
    put 'payrolls' => 'payrolls#select_dates'
    post 'payrolls' => 'payrolls#view_payroll'

    # punchcards history
    get 'punchcards/:id/history' => 'punchcards#history'

    # map view of punchcard
    get 'punchcards/map/:id' => 'punchcards#map'

    # reports
    put 'reports' => 'reports#select_report'
    post 'reports' => 'reports#view_report'

    # versions
    get 'audit_trails/:id/rollback' => 'audit_trails#rollback'
    get 'audit_trails/item_type/:item_type/item_id/:item_id(.:format)' => 'audit_trails#find_by_item_type_and_item_id'
  end
end
