class Project < ActiveRecord::Base
  has_paper_trail :on => [:update, :destroy]
  belongs_to :company
  has_many :punchcards
end