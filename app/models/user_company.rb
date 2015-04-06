class UserCompany < ActiveRecord::Base
  has_paper_trail :on => [:create, :update, :destroy]
end