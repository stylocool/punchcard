class PayrollPdf < Prawn::Document

  def initialize
    super(size: 'A5', page_layout: :landscape)
  end

  def generate(worker, period, start_date, stop_date, year, month, days, view)
    punchcards = Punchcard.where(worker_id: worker.id, checkin: start_date.utc..stop_date.utc)
    calculator = PayrollCalculator.new(punchcards, year, month, days)

    company(worker)
    payroll_message(period)
    worker_table(worker, calculator.days_worked)
    payroll_table(calculator.amount, calculator.amount_normal, calculator.amount_overtime, calculator.amount_deduction, view)
  end

  def get_payment_date(period)
    next_month = period + 1.month
    next_month.strftime('5 %B %Y')
  end

  def generate_and_merge(workers, period, start_date, stop_date, year, month, days, view)
    index = 0
    workers.each do |worker|
      punchcards = Punchcard.where(worker_id: worker.id, checkin: start_date.utc..stop_date.utc)
      calculator = PayrollCalculator.new(punchcards, year, month, days)

      company(worker)
      payroll_message(period)
      worker_table(worker, calculator.days_worked)
      payroll_table(calculator.amount, calculator.amount_normal, calculator.amount_overtime, calculator.amount_deduction, view)

      index += 1
      if index < workers.length
        start_new_page
      end
    end
  end

  def company(worker)
    text worker.company.name, size: 24, style: :bold, align: :center
    text worker.company.address, size: 12, align: :center

    #logopath =  "#{Rails.root}/public" + @worker.company.logo.url(:original)
    # remove ?
    #image logopath.partition('?')[0], width: 100, height: 100, at: [570, 570]
  end

  def payroll_message(period)
    move_down 30
    text 'Payslip for the period of ' + period.strftime('%B %Y'), align: :center, size: 18
    move_down 30
    text 'Date: ' + get_payment_date(period)
  end

  def worker_table(worker, days_worked)
    move_down 30
    table worker_details(worker, days_worked), width: 720 do
      cells.border_width = 0
      columns(1).align = :center
      columns(4).align = :center
      self.header = true
      self.column_widths = {0 => 120, 1 => 40, 2 => 200, 3 => 60, 4 => 40, 5 => 260}
    end
  end

  def worker_details(worker, days_worked)
    [
        ['Work Permit', ':', worker.work_permit, 'Name', ':', worker.name],
        ['No. of Days Worked', ':', days_worked, 'Trade', ':', worker.trade]
    ]
  end

  def payroll_table(amount, amount_normal, amount_overtime, amount_deduction, view)
    move_down 30
    table payroll_details(amount, amount_normal, amount_overtime, amount_deduction, view), width: 720 do
      cells[0, 0].borders = [:top, :bottom, :left]
      cells[0, 1].borders = [:top, :bottom, :right]
      cells[0, 2].borders = [:top, :bottom, :left]
      cells[0, 3].borders = [:top, :bottom, :right]

      cells[1, 0].borders = [:left]
      cells[1, 1].borders = [:right]
      cells[1, 2].borders = [:left]
      cells[1, 3].borders = [:right]

      cells[2, 0].borders = [:left]
      cells[2, 1].borders = [:right]
      cells[2, 2].borders = [:left]
      cells[2, 3].borders = [:right]

      cells[3, 0].borders = [:top, :bottom, :left]
      cells[3, 1].borders = [:top, :bottom, :right]
      cells[3, 2].borders = [:top, :bottom, :left]
      cells[3, 3].borders = [:top, :bottom, :right]

      cells[4, 0].borders = [:top, :bottom, :left]
      cells[4, 1].borders = [:top, :bottom, :right]
      cells[4, 2].borders = [:top, :bottom, :left]
      cells[4, 3].borders = [:top, :bottom, :right]

      cells[5, 0].borders = [:left]
      cells[5, 1].border_width = 0
      cells[5, 2].border_width = 0
      cells[5, 3].borders = [:right]

      cells[6, 0].borders = [:left]
      cells[6, 1].border_width = 0
      cells[6, 2].border_width = 0
      cells[6, 3].borders = [:right]

      cells[7, 0].borders = [:left]
      cells[7, 1].border_width = 0
      cells[7, 2].border_width = 0
      cells[7, 3].borders = [:right]

      cells[8, 0].borders = [:left]
      cells[8, 1].border_width = 0
      cells[8, 2].border_width = 0
      cells[8, 3].borders = [:right]

      cells[9, 0].borders = [:left]
      cells[9, 1].border_width = 0
      cells[9, 2].border_width = 0
      cells[9, 3].borders = [:right]

      cells[10, 0].borders = [:left]
      cells[10, 1].border_width = 0
      cells[10, 2].border_width = 0
      cells[10, 3].borders = [:right]

      cells[11, 0].borders = [:bottom, :left]
      cells[11, 1].border_width = 0
      cells[11, 2].borders = [:bottom]
      cells[11, 3].borders = [:right]

      cells[12, 0].borders = [:bottom, :left]
      cells[12, 1].borders = [:bottom]
      cells[12, 2].borders = [:bottom]
      cells[12, 3].borders = [:bottom, :right]

      self.header = true
      self.column_widths = { 0 => 180, 1 => 180, 2 => 180, 3 => 180 }
    end
  end

  def payroll_details(amount, amount_normal, amount_overtime, amount_deduction, view)
    [
      ['Earnings', 'Amount', 'Deductions', 'Amount'], # 0
      ['Basic Pay', currency(view, amount_normal), 'Deduction', currency(view, amount_deduction)], # 1
      ['Overtime', currency(view, amount_overtime), '', ''], # 2
      ['Total Earnings', currency(view, amount_normal + amount_overtime), 'Total Deductions',	currency(view, amount_deduction)], # 3
      ['Allowance/Claim', '', '', ''], # 4
      ['', '', '', ''], # 5
      ['', '', '', ''], # 6
      ['', '', '', ''], # 7
      ['', '', '', ''], # 8
      ['', '', '', ''], # 9
      ['', '', '', ''], # 10
      ['', '', '', ''], # 11
      ['Employer\'s Signature', '', 'Employee\'s Signature', ''] # 12
    ]
  end

  def currency(view, num)
    view.number_to_currency(num)
  end
end
