class Project < ActiveRecord::Base
  belongs_to :company
  has_many :punchcards
end