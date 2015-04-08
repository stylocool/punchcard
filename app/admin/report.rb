ActiveAdmin.register_page "Reports" do

  content only: :index do
    render 'index'
  end

  controller do
    def index
      @page_title = "Reports"
      @report = Report.new
      render :layout => 'active_admin'
    end

    def view_report
      @page_title = "Report"
      @report = Report.new(model_params)
      report_params = params[:report]

      year = report_params["period(1i)"].to_i
      month = report_params["period(2i)"].to_i
      day = report_params["period(3i)"].to_i

      @period = Date.new year, month, day
      days = Time.days_in_month(month, year)
      startDate = DateTime.new year, month, 1, 0, 0, 0
      endDate = DateTime.new year, month, days, 23, 59, 59
      @range = startDate..endDate

      case report_params[:report_name]
        when 'Daily Punchcards'
          @metric = Punchcard.where("checkin between ? and ?", startDate, endDate).group_by_day(:checkin).count
        when 'Daily User Logins'
          @metric = PaperTrail::Version.where("item_type = ? and event = ? and (created_at between ? and ?) and object_changes like ?", "User", "update", startDate, endDate, "%sign_in_count%").group_by_day(:created_at).count

      end

    end

    def model_params
      params.require(:report).permit(:report_name)
    end
  end
end