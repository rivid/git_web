class Workspace < ActiveRecord::Base
  validates_presence_of :path
  validate :path_must_be_valid, on: :create

  has_many :repositories

  def path_must_be_valid
    if !Dir.exists?(path)
       errors.add(:path, "workspace path can't be blank and must be accessible")
    end
  end

  def add_existing_repos
    Dir.glob("#{self.path}/*").select do |dir|
      Dir.exists?(dir)
    end.each do |dir|
      name = dir.split('/').last
      self.repositories.create(name: name)
    end
  end
end
