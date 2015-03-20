class PayrollPdf < Prawn::Document

  def initialize(payroll_id, worker, period, days_worked, amount, amount_normal, amount_overtime, amount_deduction, view)
    super(size: "A4", page_layout: :landscape)

    @view = view
    @worker = worker
    @period = period
    @days_worked = days_worked
    @amount = amount
    @amount_normal = amount_normal
    @amount_overtime = amount_overtime
    @amount_deduction = amount_deduction

    company
    payroll_message
    worker_table
    payroll_table
    #regards_message
  end

  def company
    text @worker.company.name, :size => 24, style: :bold, align: :center
    text @worker.company.address, :size => 12, align: :center

    logopath =  "#{Rails.root}/app/assets/images/logo.jpg"
    image logopath, :width => 200, :height => 100, at: [570,570]
  end

  def payroll_message
    move_down 10
    text "Payslip for for the period of " + @period.strftime("%B %Y"), align: :center
  end

  def worker_table
    move_down 10
    table worker_details, :width => 720 do
      cells.border_width = 0
      columns(1).align = :center
      columns(4).align = :center
      self.header = true
      self.column_widths = {0 => 160, 1 => 40, 2 => 160, 3 => 160, 4 => 40, 5 => 160}
    end
  end

  def worker_details
    [
        ["Employer Id", ":", @worker.id, "Name", ":", @worker.name],
        ["Department", ":", "", "Designation", ":", ""],
        ["Date of Joining", ":", @worker.created_at.strftime("%B %Y"), "PF Account Number", ":", ""],
        ["Days Worked", ":", @days_worked, "ESI Account Number", ":", ""],
        ["Bank Acct/Cheque Number", ":", "", "Next-of-Kin", ":", ""],
        ["Earn Leave", ":", "", "Casual Leave", ":", ""]
    ]
  end

  def payroll_table
    move_down 10
    table payroll_details, :width => 720 do
      #cells.border_width = 0
      # row 0
      cells[0,0].borders = [:top, :bottom, :left]
      cells[0,1].borders = [:top, :bottom, :right]
      cells[0,2].borders = [:top, :bottom, :left]
      cells[0,3].borders = [:top, :bottom, :right]

      # row 1
      cells[1,0].borders = [:left]
      cells[1,1].borders = [:right]
      cells[1,2].borders = [:left]
      cells[1,3].borders = [:right]

      # row 2
      cells[2,0].borders = [:left]
      cells[2,1].borders = [:right]
      cells[2,2].borders = [:left]
      cells[2,3].borders = [:right]

      # row 3
      cells[3,0].borders = [:left]
      cells[3,1].borders = [:right]
      cells[3,2].borders = [:left]
      cells[3,3].borders = [:right]

      # row 4
      cells[4,0].borders = [:left]
      cells[4,1].borders = [:right]
      cells[4,2].borders = [:left]
      cells[4,3].borders = [:right]

      # row 5
      cells[5,0].borders = [:left]
      cells[5,1].borders = [:right]
      cells[5,2].borders = [:left]
      cells[5,3].borders = [:right]

      # row 6
      cells[6,0].borders = [:left]
      cells[6,1].borders = [:right]
      cells[6,2].borders = [:left]
      cells[6,3].borders = [:right]

      # row 7
      cells[7,0].borders = [:top, :bottom, :left]
      cells[7,1].borders = [:top, :bottom, :right]
      cells[7,2].borders = [:top, :bottom, :left]
      cells[7,3].borders = [:top, :bottom, :right]

      # row 8
      cells[8,0].borders = [:left]
      cells[8,1].border_width = 0
      cells[8,2].border_width = 0
      cells[8,3].borders = [:right]

      # row 9
      cells[9,0].borders = [:bottom, :left]
      cells[9,1].borders = [:bottom]
      cells[9,2].borders = [:bottom]
      cells[9,3].borders = [:bottom, :right]

      # row 10
      cells[10,0].borders = [:left]
      cells[10,1].border_width = 0
      cells[10,2].border_width = 0
      cells[10,3].borders = [:right]

      # row 11
      cells[11,0].borders = [:left]
      cells[11,1].border_width = 0
      cells[11,2].border_width = 0
      cells[11,3].borders = [:right]

      # row 12
      cells[12,0].borders = [:left]
      cells[12,1].border_width = 0
      cells[12,2].border_width = 0
      cells[12,3].borders = [:right]

      # row 13
      cells[13,0].borders = [:bottom, :left]
      cells[13,1].border_width = 0
      cells[13,2].borders = [:bottom]
      cells[13,3].borders = [:right]

      # row 14
      cells[14,0].borders = [:bottom, :left]
      cells[14,1].borders = [:bottom]
      cells[14,2].borders = [:bottom]
      cells[14,3].borders = [:bottom, :right]

      self.header = true
      self.column_widths = {0 => 180, 1 => 180, 2 => 180, 3 => 180}
    end
  end

  def payroll_details
    [
        ["Earnings", "Amount", "Deductions", "Amount"],
        ["Basic Pay", currency(@amount_normal), "Employee Insurance", ""],
        ["Dearness Allowance", "", "Central Provident Fund (CPF)", ""],
        ["Medical Allowance", "",	"Goods & Serices Tax (GST)", ""],
        ["Overtime", currency(@amount_overtime), "", ""],
        ["House Rent Allowance", "", "", ""],
        ["Conveyance Allowance", "", "", ""],
        ["Total Earnings", currency(@amount_normal+@amount_overtime), "Total Deductions",	currency(@amount_deduction)],
        ["Previous Balance", "", "Net Pay (Rounded)", currency(@amount)],
        ["Carry Over Round-Off", "", "", ""],
        ["", "", "", ""], #dummy row
        ["", "", "", ""], #dummy row
        ["", "", "", ""], #dummy row
        ["", "", "", ""], #dummy row
        ["Employer's Signature", "", "Employee's Signature", ""]
    ]
  end

  def currency(num)
    @view.number_to_currency(num)
  end


end