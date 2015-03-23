class Punchcard < ActiveRecord::Base
  has_paper_trail :on => [:update, :destroy]
  belongs_to :worker
  belongs_to :project
  belongs_to :company
end