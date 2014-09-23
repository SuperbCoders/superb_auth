class SuperbAuth::IdentitiesController < SuperbAuth::ApplicationController
  before_action :authenticate_user!

  # DELETE /identities/:provider
  def destroy
    @identity = current_user.identities.where(provider: params[:provider]).first
    if (current_user.email.present? && current_user.encrypted_password.present?) || current_user.identities.count > 1
      destroy_identity
    else
      redirect_after_could_not_be_destroyed
    end
  end

  protected

    def destroy_identity
      if @identity.try(:destroy)
        redirect_after_destroy_success
      else
        redirect_after_destroy_fail
      end
    end

    def redirect_after_destroy_success
      redirect_to main_app.edit_user_registration_url, notice: "Привязка к #{params[:provider]} удалена"
    end

    def redirect_after_destroy_fail
      redirect_to main_app.edit_user_registration_url, alert: "Не удалось удалить привязку к #{params[:provider]}"
    end

    def redirect_after_could_not_be_destroyed
      redirect_to main_app.edit_user_registration_url, alert: "Чтобы удалить привязку к #{params[:provider]}, укажите email и пароль, либо привяжите другую социальную сеть"
    end

end
