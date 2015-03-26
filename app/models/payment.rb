class Payment < ActiveRecord::Base
  has_paper_trail :on => [:create, :update, :destroy]
  belongs_to :company

  # validations
  validates :total_workers, presence: true, numericality: {only_integer: true, :greater_than => 0}
  #validates_numericality_of :total_workers, :rate_per_month, :months_of_service, :amount, :greater_than_or_equal_to => 1

end