class PayrollWorkItem
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :date, :total

  @punchcards = []

  def initialize
    @punchcards = []
  end

  def get_punchcards
    @punchcards
  end

  def add_punchcard(punchcard)
    @punchcards.push punchcard
  end
end