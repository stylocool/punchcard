class CompanySetting < ActiveRecord::Base
  has_paper_trail on: [:create, :update, :destroy]

  belongs_to :company

  # validations
  validates :name, :distance_check, :overtime_rate, :working_hours, :company_id, presence: true
  validates_numericality_of :distance_check, greater_than_or_equal_to: 0
  validates_numericality_of :overtime_rate, :working_hours, greater_than_or_equal_to: 1
end