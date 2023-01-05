class TenantsController < ApplicationController
  before_action :set_tenant
  def edit
  end

  def update
    Tenant.transaction do
      if @tenant.update(tenant_params)
        if @tenant.plan == "premium" && @tenant.payment.blank?
          @payment = Payment.new(token: params[:payment][:token],
            email: current_user.email,
            tenant: @tenant)
          flash[:error] = "Please check registration errors" unless @payment.valid?

          begin
            @payment.process_payment
            @payment.save
          rescue => exception
            flash[:error] = e.message
            @payment.destroy
            log_action("Payment failed")
            @tenant.plan = "free"
            @tenant.save

            redirect_to edit_tenant_path(@tenant) and return
          end
        end
        redirect_to edit_plan_path, notice: "Plan was successfully updated"
      else
        render :edit
      end
    end
  end

  def change
    @tenant= Tenant.find(params[:id])
    Tenant.set_current_tenant @tenant.id
    session[:tenant_id] = Tenant.current_tenant.id
    flash[:success] = "Switched to organization #{@tenant.name}"
    redirect_to home_index_path
  end

  private

  def set_tenant
    @tenant = Tenant.current_tenant
  end

  def tenant_params
    params.require(:tenant).permit(:name, :plan)
  end

end
