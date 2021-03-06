class PayrollCalculator

  attr_accessor :amount, :amount_deduction, :amount_normal, :amount_overtime, :amount_fine, :days_worked, :items

  def initialize(punchcards, year, month, days)
    @amount = 0
    @amount_deduction = 0
    @amount_normal = 0
    @amount_overtime = 0
    @amount_fine = 0
    @days_worked = 0
    @items = []

    calculate(punchcards, year, month, days)
  end

  def calculate(punchcards, year, month, days)

    (0..days - 1).each do |index|
      item = PayrollWorkItem.new
      item.date = Date.new year, month, index + 1
      @items.push item
    end

    if punchcards.count > 0
      punchcards.each do |punchcard|
        punchcard.calculate
        work = @items[punchcard.checkin.day - 1]
        work.total += punchcard.amount_minutes.to_f
        work.add_punchcard(punchcard)

        if work.get_punchcards.length == 1
          @days_worked += 1
        end

        @amount += punchcard.amount_minutes
        @amount_deduction += punchcard.amount_deduction_minutes
        @amount_normal += punchcard.amount_normal_minutes
        @amount_overtime += punchcard.amount_overtime_minutes
        if punchcard.fine.to_f > 0
          @amount_fine += punchcard.fine.to_f
        end
      end
    end
  end
end