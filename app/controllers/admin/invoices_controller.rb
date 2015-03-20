class Admin::InvoicesController < ApplicationController
  include Wicked::Wizard

  before_filter :authenticate_active_admin_user!

  steps :select_type, :select_dates, :view_invoice

  def show
    logger.debug("Show")
    @invoice = Payroll.new
    render_wizard
  end

  def update

    case step
      when :select_dates
        @invoice = Payroll.new(model_params)
        logger.debug("Select datas")
        if @invoice.type == 'Company'
          @objects = Company.all#where(:id => current_user.current_company.id)

        else
          @objects = Worker.all#where(:company_id => current_user.current_company.id)

        end

      when :view_invoice
        invoice_params = params[:invoice]
        start_date = Date.new invoice_params["start(1i)"].to_i, invoice_params["start(2i)"].to_i, invoice_params["start(3i)"].to_i
        stop_date = Date.new invoice_params["stop(1i)"].to_i, invoice_params["stop(2i)"].to_i, invoice_params["stop(3i)"].to_i

        respond_to do |format|
          format.html do
            if invoice_params[:type] == 'Company'

            else
              @worker = Worker.find(invoice_params[:object_id])
              @punchcards = Punchcard.where("worker_id = ? and checkin >= ? and checkout <= ?", invoice_params[:object_id], start_date, stop_date)
              @amount = 0
              if @punchcards.count > 0
                @items = []
                index = 0
                @punchcards.each do |punchcard|
                  work = PayrollWorkItem.new(punchcard)
                  @amount += work.amount
                  @items.push work
                end
              end
            end
          end
          format.pdf do
            if invoice_params[:type] == 'Company'

            else
              worker = Worker.find(invoice_params[:object_id])
              punchcards = Punchcard.where("worker_id = ? and checkin >= ? and checkout <= ?", invoice_params[:object_id], start_date, stop_date)
              amount = 0
              if punchcards.count > 0
                items = []
                index = 0
                punchcards.each do |punchcard|
                  work = PayrollWorkItem.new(punchcard)
                  amount += work.amount
                  items.push work
                end
              end

              invoice_id = Time.now.strftime("%d%m%Y%H%M%S")
              message = "Payroll for the work done"
              pdf = PayrollPdf.new(invoice_id, worker.name, message, start_date, stop_date, amount, items, view_context)
              send_data pdf.render, filename: "invoice_#{invoice_id}.pdf", type: "application/pdf", disposition: "inline"
            end
          end
        end
    end
    render_wizard @invoice
  end

  def model_params
    params.require(:invoice).permit(:type, :object_id, :start, :stop)
  end
end