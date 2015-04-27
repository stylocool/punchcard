require 'zip'
ActiveAdmin.register_page 'Payrolls' do

  content only: :index do
    render 'index'
  end

  controller do
    def index
      @page_title = 'Payrolls'
      @payroll = Payroll.new
      render layout: 'active_admin'
    end

    def select_dates
      @page_title = 'Payrolls'
      @payroll = Payroll.new
      @payroll.type = params[:type]
      if current_user.role == 'Root'
        @objects = Worker.all
      else
        @objects = Worker.where(company_id: current_user.current_company.id)
      end
      render layout: 'active_admin'
    end

    def view_payroll
      payroll_params = params[:payroll]

      if payroll_params[:mode] == 'Details'
        @page_title = 'Payrolls'
        @payroll = Payroll.new(model_params)

        year = payroll_params['period(1i)'].to_i
        month = payroll_params['period(2i)'].to_i
        day = payroll_params['period(3i)'].to_i

        @period = Date.new year, month, day
        days = Time.days_in_month(month, year)

        # need to convert to utc to query database
        start_date = Time.zone.parse(@period.strftime('%Y-%m-01 00:00:00')).utc
        stop_date = Time.zone.parse(@period.strftime("%Y-%m-#{days} 00:00:00")).utc

        # processing worker payroll
        @worker = Worker.find(payroll_params[:object_id])
        @punchcards = Punchcard.where(worker_id: @worker.id, checkin: start_date.utc..stop_date.utc)

        calculator = PayrollCalculator.new(@punchcards, year, month, days)
        @days_worked = calculator.days_worked
        @amount = calculator.amount
        @amount_normal = calculator.amount_normal
        @amount_overtime = calculator.amount_overtime
        @amount_deduction = calculator.amount_deduction
        @items = calculator.items

        render layout: 'active_admin'
      else
        view_payroll_summary
      end
    end

    def view_payroll_summary
      @page_title = 'Payrolls'
      @payroll = Payroll.new(model_params)
      payroll_params = params[:payroll]
      year = payroll_params['period(1i)'].to_i
      month = payroll_params['period(2i)'].to_i
      day = payroll_params['period(3i)'].to_i
      @period = Date.new year, month, day
      days = Time.days_in_month(month, year)

      # need to convert to utc to query database
      start_date = Time.zone.parse(@period.strftime('%Y-%m-01 00:00:00')).utc
      stop_date = Time.zone.parse(@period.strftime("%Y-%m-#{days} 00:00:00")).utc

      if payroll_params[:object_id] == '0'
        # create zip file
        stringio = Zip::OutputStream.write_buffer do |zio|
          # all workers
          workers = Worker.where(company_id: current_user.current_company.id)
          workers.each do |worker|
            payroll_id = generate_payroll_id(worker, @period)
            pdf = generate_worker_pdf(worker, @period, start_date, stop_date, year, month, days)
            zio.put_next_entry("payroll_#{payroll_id}.pdf")
            zio << pdf.render
          end
        end
        stringio.rewind
        binary_data = stringio.sysread
        send_data binary_data, filename: "payrolls_#{@period.strftime('%B_%Y')}.zip", type: 'application/zip', disposition: 'attachment'

      else
        # individual worker
        @worker = Worker.find(payroll_params[:object_id])
        if payroll_params[:format] == 'HTML'
          punchcards = Punchcard.where(worker_id: @worker.id, checkin: start_date.utc..stop_date.utc)
          calculator = PayrollCalculator.new(punchcards, year, month, days)
          @days_worked = calculator.days_worked
          @amount = calculator.amount
          @amount_normal = calculator.amount_normal
          @amount_overtime = calculator.amount_overtime
          @amount_deduction = calculator.amount_deduction
          render :view_payroll_summary
        else
          payroll_id = generate_payroll_id(@worker, @period)
          pdf = generate_worker_pdf(@worker, @period, start_date, stop_date, year, month, days)
          send_data pdf.render, filename: "payroll_#{payroll_id}.pdf", type: 'application/pdf', disposition: 'inline'
        end
      end
    end

    def generate_worker_pdf(worker, period, start_date, stop_date, year, month, days)
      punchcards = Punchcard.where(worker_id: worker.id, checkin: start_date.utc..stop_date.utc)
      calculator = PayrollCalculator.new(punchcards, year, month, days)
      pdf = PayrollPdf.new(worker, period, calculator.days_worked, calculator.amount, calculator.amount_normal, calculator.amount_overtime, calculator.amount_deduction, view_context)
    end

    def generate_payroll_id(worker, period)
      payroll_id = worker.name.tr(' ', '_') + '_' + period.strftime('%B_%Y')
    end

    def model_params
      params.require(:payroll).permit(:type, :object_id)
    end
  end
end
