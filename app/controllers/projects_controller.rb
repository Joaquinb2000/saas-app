class ProjectsController < ApplicationController
  before_action :set_project, only: %i[ show edit update destroy users add_user ]
  before_action :set_tenant, except: [ :index ]
  before_action :verify_tenant

  # GET /projects/1 or /projects/1.json
  def show
  end

  # GET /projects/new
  def new
    @project = Project.new
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects or /projects.json
  def create
    @project = Project.new(project_params)
    @project.users << current_user

    respond_to do |format|
      if @project.save
        format.html { redirect_to root_url, notice: "Project was successfully created." }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /projects/1 or /projects/1.json
  def update
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to root_url, notice: "Project was successfully updated." }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /projects/1 or /projects/1.json
  def destroy
    @project.destroy

    respond_to do |format|
      format.html { redirect_to root_url, notice: "Project was successfully destroyed." }
    end
  end

  def users
    @project_users = (@project.users + (User.where(tenant_id: @tenant.id, is_admin: true))) - [current_user]
    @other_users = @tenant.users.where(is_admin: false) - (@project_users - [current_user])
  end

  def add_user
    user = @tenant.users.find_by(id: params[:user_id])
    user_project = UserProject.find_by(user_id: params[:user_id], project_id: params[:project_id])

    if user && user_project.nil?
      @project.users << user
      flash[:notice] = "User succesfully added"
      redirect_to users_tenant_project_url(id: @project.id, tenant_id: @project.tenant.id)
    else
      message = !user_project.nil? ? "User is already a project member" : "User could not be added"
      flash[:error] = message
      redirect_to users_tenant_project_url(id: @project.id, tenant_id: @project.tenant.id)
    end


  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def project_params
      params.require(:project).permit(:title, :details, :expected_completion_date, :tenant_id)
    end

    def set_tenant
      @tenant = Tenant.find(params[:tenant_id])
    end

    def verify_tenant
      unless params[:tenant_id] == Tenant.current_tenant_id.to_s
        flash[:error] = "You are not part of this organization"
        redirect_to root_path
      end
    end
end
