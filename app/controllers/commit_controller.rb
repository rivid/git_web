class CommitController < ApplicationController
  def show
    @workspace = Workspace.find(params[:workspace_id])
    repo = Repository.find_by_slug(params[:repository_id])
    if repo
      @repository = Rugged::Repository.new("#{@workspace.path}/#{repo.name}")
      @commit = @repository.lookup(params[:id])
    else
      render 'public/404' and return
    end
  end

  def create
    @workspace = Workspace.find(params[:workspace_id])
    repo = Repository.find_by_slug(params[:repository_id])
    if repo
      @repository = Rugged::Repository.new("#{@workspace.path}/#{repo.name}")
      require 'byebug'; byebug

      index = @repository.index
      index.read_tree(@repository.branches[params[:tree]].target.tree)

      create_commit_params.each do |file|
        index.add(file)
      end
      index.write

      options = {}
      options[:tree] = index.write_tree(@repository)

      options[:author] = { :email => "testuser@github.com", :name => 'Test Author', :time => Time.now }
      options[:committer] = { :email => "testuser@github.com", :name => 'Test Author', :time => Time.now }
      options[:message] ||= params[:message] || "Making a commit via Rugged!"
      options[:parents] = @repository.empty? ? [] : [ @repository.branches[params[:tree]].target ].compact
      options[:update_ref] = 'HEAD'

      Rugged::Commit.create(@repository, options)
      options = { strategy: :force }
      @repository.checkout_head(options)
      redirect_to workspace_repository_tree_path(@workspace, repo, params[:tree])
    else
      render 'public/404' and return
    end
  end

  private
  def create_commit_params
    params.require(:commits).require(:files)
  end
end
