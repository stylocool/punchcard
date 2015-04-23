class CompanySetting < ActiveRecord::Base
  has_paper_trail :on => [:create, :update, :destroy]

  belongs_to :company

  # validations
  validates :name, :distance_check, :overtime_rate, :company_id, presence: true
  validates :working_hours, presence: true, numericality: { only_integer: true, :greater_than => 0 }
  validates_numericality_of :distance_check, :greater_than_or_equal_to => 0
  validates_numericality_of :overtime_rate, :greater_than_or_equal_to => 1
end