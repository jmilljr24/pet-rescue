class Organizations::Staff::UserRolesController < Organizations::BaseController
  before_action :set_user

  def to_staff
    ActiveRecord::Base.transaction do
      @user.add_role :staff, Current.organization
      @user.remove_role :admin, Current.organization
      raise ActiveRecord::Rollback if @user.has_role?(:admin, Current.organization) || !@user.has_role?(:staff, Current.organization)

      respond_to do |format|
        format.html { redirect_to request.referrer, notice: "Account changed to Staff" }
        format.turbo_stream { flash.now[:notice] = "Account changed to Staff" }
      end
    end

    respond_to do |format|
      format.html { redirect_to request.referrer, notice: "Error changing role" }
      format.turbo_stream { flash.now[:notice] = "Error changing role" }
    end
  end

  def to_admin
    ActiveRecord::Base.transaction do
      @user.add_role :admin, Current.organization
      @user.remove_role :staff, Current.organization
      raise ActiveRecord::Rollback if @user.has_role?(:staff, Current.organization) || !@user.has_role?(:admin, Current.organization)

      respond_to do |format|
        format.html { redirect_to request.referrer, notice: "Account changed to Admin" }
        format.turbo_stream { flash.now[:notice] = "Account changed to Admin" }
      end
    end
    respond_to do |format|
      format.html { redirect_to request.referrer, alert: "Error changing role" }
      format.turbo_stream { flash.now[:alert] = "Error changing role" }
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
    authorize! @user, with: Organizations::UserRolesPolicy, to: :change_role?
  end
end
