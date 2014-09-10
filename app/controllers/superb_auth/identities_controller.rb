class SuperbAuth::IdentitiesController < SuperbAuth::ApplicationController
  before_action :authenticate_user!

  # DELETE /identities/:provider
  def destroy
    @identity = current_user.identities.where(provider: params[:provider]).first
    if (current_user.email.present? && current_user.encrypted_password.present?) || current_user.identities.count > 1
      destroy_identity
    else
      redirect_to main_app.edit_user_registration_url, alert: "Чтобы удалить привязку к #{params[:provider]}, укажите email и пароль, либо привяжите другую социальную сеть"
    end
  end

  private

    def destroy_identity
      if @identity.try(:destroy)
        redirect_to main_app.edit_user_registration_url, notice: "Привязка к #{params[:provider]} удалена"
      else
        redirect_to main_app.edit_user_registration_url, alert: "Не удалось удалить привязку к #{params[:provider]}"
      end
    end
end