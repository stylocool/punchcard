class Report
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :report_name, :project_id, :period

  def save
    # do nothing
  end
end
