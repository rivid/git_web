class AddWorkspaceIdToRepositories < ActiveRecord::Migration
  def change
    add_column :repositories, :workspace_id, :integer, index: true
  end
end
