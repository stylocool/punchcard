ActiveAdmin.register_page 'Reports' do
  content only: :index do
    render 'index'
  end

  controller do
    def index
      @page_title = 'Reports'
      @report = Report.new
      render layout: 'active_admin'
    end

    def view_report
      @page_title = 'Report'
      @report = Report.new(model_params)
      report_params = params[:report]

      year = report_params['period(1i)'].to_i
      month = report_params['period(2i)'].to_i
      day = report_params['period(3i)'].to_i

      @period = Date.new year, month, day
      days = Time.days_in_month(month, year)
      start_date = DateTime.new year, month, 1, 0, 0, 0
      stop_date = DateTime.new year, month, days, 23, 59, 59

      case report_params[:report_name]
      when 'Daily Punchcards'
        if current_user.role? :Root
          @metric = Punchcard.where('checkin between ? and ?', start_date, stop_date).group_by_day(:checkin).count
        else
          @metric = Punchcard.where('company_id = ? and checkin between ? and ?', current_user.current_company.id, start_date, stop_date).group_by_day(:checkin).count
        end
      when 'Daily User Logins'
        if current_user.role? :Root
          @metric = PaperTrail::Version.where('item_type = ? and event = ? and (created_at between ? and ?) and object_changes like ?', 'User', 'update', start_date, stop_date, '%sign_in_count%').group_by_day(:created_at).count
        else
          @metric = PaperTrail::Version.where('whodunnit in (select user_id from user_companies where company_id = ?) and item_type = ? and event = ? and (created_at between ? and ?) and object_changes like ?', current_user.current_company.id, 'User', 'update', start_date, stop_date, '%sign_in_count%').group_by_day(:created_at).count
        end
      when 'Daily Payouts'

        if current_user.role? :Root
          @punchcards = Punchcard.where('checkin between ? and ?', start_date, stop_date)
        else
          @punchcards = Punchcard.where('company_id = ? and checkin between ? and ?', current_user.current_company.id, start_date, stop_date)
        end
        @items = []

        (0..days - 1).each do |index|
          item = PayrollWorkItem.new
          item.date = Date.new year, month, index + 1
          item.total = 0.0
          @items.push item
        end

        if @punchcards.count > 0
          @punchcards.each do |punchcard|
            punchcard.calculate
            item = @items[punchcard.checkin.day - 1]
            item.total = item.total + punchcard.amount.to_f
          end
        end

        @metric = []
        (0..days - 1).each do |index|
          item = @items[index]
          @metric.push [item.date.to_s, item.total]
        end
        @metric
      end
    end

    def model_params
      params.require(:report).permit(:report_name)
    end
  end
end
