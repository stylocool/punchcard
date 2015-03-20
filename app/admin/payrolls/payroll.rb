class Payroll
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :type, :object_id, :period, :format, :mode

  def save
    # do nothing
  end
end
