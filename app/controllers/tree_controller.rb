require 'find'
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

      @diff = @repository.index.diff
      #unstaged files, with .gitignore
      ignore_patterns = [/\/\.git/]
      File.open("#{@workspace.path}/#{@repo.name}/.gitignore").each_line do |line|
        next if line =~ /^\s*$/
        next if line =~ /\s*#/
        line = line.chop
        line.gsub!('*', ".*")
        line.gsub!('..*', ".*")
        ignore_patterns << Regexp.new(line)
      end

      repo_files = Find.find("#{@workspace.path}/#{@repo.name}").select do |file|
        fname = file.gsub("#{@workspace.path}/#{@repo.name}", '')
        !Dir.exists?(file) &&
          !ignore_patterns.map{|regex| !regex.match(fname).nil?}.any?
      end.map do |fname|
        fname.gsub("#{@workspace.path}/#{@repo.name}/", '')
      end

      @untracked_files = repo_files.select do |fname|
        @repository.index[fname].nil?
      end

    else
      render 'public/404' and return
    end

  end
end
