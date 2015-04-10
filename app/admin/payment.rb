ActiveAdmin.register Payment do
  permit_params :total_workers, :rate_per_month, :months_of_service, :amount,
                :mode, :reference_number, :company_id, :status

  after_save :calculate_amount

  controller do
    def new
      @payment = Payment.new
      @payment.total_workers = current_user.current_company.total_workers
      @payment.rate_per_month = 1
    end

    def calculate_amount(payment)
      if payment.status.to_s == ''
        # new payment
        payment.status = 'new'
        # this is hardcoded for per month
        payment.rate_per_month = 1
        payment.amount = payment.total_workers * payment.rate_per_month *
          payment.months_of_service
        if payment.save
          # TODO: payment gateway
          # send payment details to company email
          PaymentMailer.send_payment(payment).deliver_now
        end
      else
        # update payment
        payment.status = 'paid' if
          payment.status.to_s == 'new' && payment.reference_number.present?
        payment.save
      end
    end

    def find_resource
      @payment = Payment.where(id: params[:id]).first!
      return @payment if current_user.role? :Root
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
    f.inputs 'Payment Details' do
      f.input :company, as: :select, include_blank: false, collection:
        if current_user.role? :Root
          Company.all.map { |u| ["#{u.name}", u.id] }
        elsif current_user.role? :Administrator
          user_company = UserCompany.find_by_user_id(current_user.id)
          if user_company.present?
            Company.all.where(id: user_company.company_id).map { |u| ["#{u.name}", u.id] }
          else
            Company.none
          end
        end
      f.input :total_workers, as: :number
      f.input :months_of_service, as: :select, include_blank: false, collection: ((1..12).map { |i| [i, i] })
      f.input :mode, as: :select, include_blank: false, collection: { InternetBanking: 'Internet Banking', PayPal: 'PayPal'}
      f.input :reference_number
      if current_user.role? :Root
        f.input :status, as: :select, include_blank: false, collection: { Acknowledged: 'ack' }
      end
    end
    f.actions
  end
end
