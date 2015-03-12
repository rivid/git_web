class Repository < ActiveRecord::Base
  validates_presence_of :name, on: :create
  validates_uniqueness_of :name, :scope => :workspace_id

  belongs_to :workspace

  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  def slug_candidates
    name
  end
end
