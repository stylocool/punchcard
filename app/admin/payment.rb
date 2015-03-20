ActiveAdmin.register Payment do

  permit_params :total_workers, :rate_per_month, :months_of_service, :amount, :mode, :reference_number, :company_id, :status, :amount

  after_create :calculate_amount

  controller do
    #def index
    #  index! do |format|
    #    if current_user.role? :Root
    #      @payments = Payment.all.page(params[:page])
    #    else
    #      if current_user.current_company.present?
    #        @payments = Payment.where(:company_id => current_user.current_company.id).page(params[:page])
    #      else
    #        @payments = Payment.none
    #      end
    #    end
    #    format.html
    #  end
    #end

    def new
      @payment = Payment.new
      @payment.total_workers = current_user.current_company.total_workers
      @payment.rate_per_month = 1
    end

    def calculate_amount(payment)
      payment.status = "new"
      payment.amount = payment.total_workers * payment.rate_per_month * payment.months_of_service
      if payment.save

        if payment.mode == :InternetBanking
          # TODO: e-nets integration
        elsif @payment.mode == :PayPal
          # TODO: paypal integration
        end

        # TODO: create payroll

        # send payment details to company email
        PaymentMailer.send_payment(@payment).deliver_now
      end

    end

    def update
      @payment.update(get_params)
    end

    def find_resource
      @payment = Payment.where(id: params[:id]).first!
      if current_user.role? :Root
        @payment
      else
        if current_user.current_company.present?
          if @payment.company_id == current_user.current_company.id
            @payment
          else
            :access_denied
          end
        else
          :access_denied
        end
      end
    end

    def get_params
      params.require(:payment).permit(:total_workers, :rate_per_month, :months_of_service, :amount, :mode, :reference_number, :company_id, :status, :amount)
    end
  end

  index do
    selectable_column
    id_column
    column :company
    column :total_workers
    column :rate_per_month
    column :months_of_service
    column :amount
    column :mode
    column :reference_number
    column :status
    column :created_at
    actions
  end

  filter :created_at
  filter :status

  form do |f|
      f.inputs "Payment Details" do
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
      f.input :total_workers
      f.input :rate_per_month, :readonly => true
      f.input :months_of_service, as: :select, include_blank: false, collection: ((1..12).map {|i| [i,i] })
      #f.input :amount
      f.input :mode, as: :select, include_blank: false, collection: { InternetBanking: 'Internet Banking', PayPal: 'PayPal'}
      f.input :reference_number
    end
    f.actions
  end

end
