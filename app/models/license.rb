class License < ActiveRecord::Base
  has_paper_trail :on => [:create, :update, :destroy]
  belongs_to :company

  # validations
  validates :cost_per_worker, :name, :total_workers, presence: true
  validates_numericality_of :cost_per_worker, :total_workers, :greater_than_or_equal_to => 1

end