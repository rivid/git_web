class WorkspacesController < ApplicationController
  def index
    @workspaces = Workspace.all
  end

  def create
    @workspace = Workspace.new(create_workspace_params)
    if @workspace.save
      @workspace.add_existing_repos
      flash[:notice] = "created!"
    else
      flash[:error] = @workspace.errors.full_messages
    end
    redirect_to workspaces_path
  end

  def show
    @workspace = Workspace.find(params[:id])
    @repositories = @workspace.repositories
  end


  private
  def create_workspace_params
    params.require(:workspace).permit(:path)
  end

end
