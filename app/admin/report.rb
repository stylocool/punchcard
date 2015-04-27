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

      # need to convert to utc to query database
      start_date = Time.zone.parse(@period.strftime('%Y-%m-01 00:00:00')).utc
      stop_date = Time.zone.parse(@period.strftime("%Y-%m-#{days} 00:00:00")).utc

      case report_params[:report_name]
      when 'Daily Punchcards'
        if current_user.role == 'Root'
          if (report_params[:project_id].present? && report_params[:project_id].to_i > 0)
            @metric = Punchcard.where(checkin: start_date..stop_date, project_id: report_params[:project_id].to_i).group_by_day(:checkin, format: '%Y-%m-%d').count
          else
            @metric = Punchcard.where(checkin: start_date..stop_date).group_by_day(:checkin, format: '%Y-%m-%d').count
          end
        else
          if (report_params[:project_id].present? && report_params[:project_id].to_i > 0)
            @metric = Punchcard.where(checkin: start_date..stop_date, company_id: current_user.current_company.id, project_id: report_params[:project_id].to_i).group_by_day(:checkin, format: '%Y-%m-%d').count
          else
            @metric = Punchcard.where(checkin: start_date..stop_date, company_id: current_user.current_company.id).group_by_day(:checkin, format: '%Y-%m-%d').count
          end
        end
      when 'Daily User Logins'
        if current_user.role == 'Root'
          @metric = PaperTrail::Version.where('item_type = ? and event = ? and (created_at between ? and ?) and object_changes like ?', 'User', 'update', start_date, stop_date, '%sign_in_count%').group_by_day(:created_at, format: '%Y-%m-%d').count
        else
          @metric = PaperTrail::Version.where('whodunnit in (select user_id::text from user_companies where company_id = ?) and item_type = ? and event = ? and (created_at between ? and ?) and object_changes like ?', current_user.current_company.id, 'User', 'update', start_date, stop_date, '%sign_in_count%').group_by_day(:created_at, format: '%Y-%m-%d').count
        end
      when 'Daily Payouts'

        if current_user.role == 'Root'
          if (report_params[:project_id].present? && report_params[:project_id].to_i > 0)
            @punchcards = Punchcard.where(checkin: start_date..stop_date, project_id: report_params[:project_id].to_i)
          else
            @punchcards = Punchcard.where(checkin: start_date..stop_date)
          end
        else
          if (report_params[:project_id].present? && report_params[:project_id].to_i > 0)
            @punchcards = Punchcard.where(company_id: current_user.current_company.id, checkin: start_date..stop_date, project_id: report_params[:project_id].to_i)
          else
            @punchcards = Punchcard.where(company_id: current_user.current_company.id, checkin: start_date..stop_date)
          end
        end

        calculator = PayrollCalculator.new(@punchcards, year, month, days)
        @items = calculator.items

        @metric = []
        (0..days - 1).each do |index|
          item = @items[index]
          @metric.push [item.date.to_s, item.total]
        end
        @metric
      end
    end

    def model_params
      params.require(:report).permit(:report_name, :project_id)
    end
  end
end
