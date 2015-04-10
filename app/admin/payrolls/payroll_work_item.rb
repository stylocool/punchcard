class PayrollWorkItem
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :punchcard, :date, :total

end