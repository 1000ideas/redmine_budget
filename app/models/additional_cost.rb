class AdditionalCost < ActiveRecord::Base
  unloadable

  attr_accessible :name, :cost, :issue_id

  validates :name, presence: true
  validates :cost, presence: true, numericality: true

  belongs_to :issue
end
