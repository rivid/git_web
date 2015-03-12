class TreeController < ApplicationController
  def show
    @workspace = Workspace.find(params[:workspace_id])
    @repo = Repository.find_by_slug(params[:repository_id])
    tree = params[:id] || 'master'
    if @repo
      @repository = Rugged::Repository.new("#{@workspace.path}/#{@repo.name}")
      @branche_names = @repository.branches.each_name(:local)
      @branch = @repository.branches["#{tree}"]
      walker = Rugged::Walker.new(@repository)
      walker.sorting(Rugged::SORT_TOPO | Rugged::SORT_REVERSE) # optional
      #walker.push(@repository.head.target_id)
      walker.push(@branch.target_id)
      @commits = []
      walker.each do |commit|
        @commits.push(commit)
      end

      #require 'byebug'; byebug
      @diff = @repository.index.diff
      #@dif_files = @diff.each_delta{ |d| puts d.inspect }
      #unstaged files, with .gitignore
      #@repository.index.entries

    else
      render 'public/404' and return
    end

  end
end
