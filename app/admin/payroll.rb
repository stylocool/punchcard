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
      if current_user.role? :Root
        @objects = Worker.all
      else
        @objects = Worker.where(company_id: current_user.current_company.id)
      end
      render layout: 'active_admin'
    end

    def view_payroll
      @page_title = 'Payrolls'
      @payroll = Payroll.new(model_params)
      payroll_params = params[:payroll]

      if payroll_params[:mode] == 'Details'
        year = payroll_params['period(1i)'].to_i
        month = payroll_params['period(2i)'].to_i
        day = payroll_params['period(3i)'].to_i

        @period = Date.new year, month, day
        days = Time.days_in_month(month, year)

        start_date = @period
        stop_date = Date.new year, month, days

        @amount = 0
        @amount_deduction = 0
        @amount_normal = 0
        @amount_overtime = 0
        @days_worked = 0

        # processing worker payroll
        @worker = Worker.find(payroll_params[:object_id])
        @punchcards = Punchcard.where('worker_id = ? and checkin >= ? and checkout <= ?', payroll_params[:object_id], start_date, stop_date)
        @amount = 0
        @items = []

        (0..days - 1).each do |index|
          item = PayrollWorkItem.new
          item.date = Date.new year, month, index + 1
          @items.push item
        end

        if @punchcards.count > 0
          @days_worked = @punchcards.count
          @punchcards.each do |punchcard|
            punchcard.calculate
            work = @items[punchcard.checkin.day - 1]
            work.punchcard = punchcard

            @amount += punchcard.amount_minutes
            @amount_deduction += punchcard.amount_deduction_minutes
            @amount_normal += punchcard.amount_normal_minutes
            @amount_overtime += punchcard.amount_overtime_minutes
          end
        end

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
      start_date = @period
      stop_date = Date.new year, month, days

      if payroll_params[:object_id] == '0'
        # create zip file
        stringio = Zip::OutputStream.write_buffer do |zio|
          # all workers
          workers = Worker.where(company_id: current_user.current_company.id)
          workers.each do |worker|
            @punchcards = Punchcard.where('worker_id = ? and checkin >= ? and checkout <= ?', worker.id, start_date, stop_date)
            @amount = 0
            @amount_deduction = 0
            @amount_normal = 0
            @amount_overtime = 0
            @days_worked = 0
            @items = []

            (0..days - 1).each do |index|
              item = PayrollWorkItem.new
              item.date = Date.new year, month, index + 1
              @items.push item
            end

            if @punchcards.count > 0
              @days_worked = @punchcards.count
              @punchcards.each do |punchcard|
                punchcard.calculate
                work = @items[punchcard.checkin.day - 1]
                work.punchcard = punchcard

                @amount += punchcard.amount_minutes
                @amount_deduction += punchcard.amount_deduction_minutes
                @amount_normal += punchcard.amount_normal_minutes
                @amount_overtime += punchcard.amount_overtime_minutes
              end
            end

            payroll_id = worker.name.tr(' ', '_') + '_' + @period.strftime('%B_%Y')
            pdf = PayrollPdf.new(payroll_id, worker, @period, @days_worked, @amount, @amount_normal, @amount_overtime, @amount_deduction, view_context)

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
        @punchcards = Punchcard.where('worker_id = ? and checkin >= ? and checkout <= ?', payroll_params[:object_id], start_date, stop_date)
        @amount = 0
        @amount_deduction = 0
        @amount_normal = 0
        @amount_overtime = 0
        @days_worked = 0
        @items = []

        (0..days - 1).each do |index|
          item = PayrollWorkItem.new
          item.date = Date.new year, month, index + 1
          @items.push item
        end

        if @punchcards.count > 0
          @days_worked = @punchcards.count
          @punchcards.each do |punchcard|
            punchcard.calculate
            work = @items[punchcard.checkin.day - 1]
            work.punchcard = punchcard

            @amount += punchcard.amount_minutes
            @amount_deduction += punchcard.amount_deduction_minutes
            @amount_normal += punchcard.amount_normal_minutes
            @amount_overtime += punchcard.amount_overtime_minutes
          end
        end

        if payroll_params[:format] == 'HTML'
          render :view_payroll_summary
        else
          payroll_id = @worker.name.tr(' ', '_') + '_' + Time.now.strftime('%d%m%Y%H%M%S')
          pdf = PayrollPdf.new(payroll_id, @worker, @period, @days_worked, @amount, @amount_normal, @amount_overtime, @amount_deduction, view_context)
          send_data pdf.render, filename: "payroll_#{payroll_id}.pdf", type: 'application/pdf', disposition: 'inline'
        end
      end
    end

    def model_params
      params.require(:payroll).permit(:type, :object_id)
    end
  end
end
