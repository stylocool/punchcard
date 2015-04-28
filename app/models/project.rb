class Project < ActiveRecord::Base
  has_paper_trail on: [:create, :update, :destroy]

  belongs_to :company
  has_many :punchcards, dependent: :destroy

  # validations
  validates :name, :location, :company_id, presence: true
  validates_format_of :location, :with => /(\d)+.(\d)+,(\d)+.(\d)+/
end