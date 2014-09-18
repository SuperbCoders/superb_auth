class SuperbAuth::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  # GET/POST /users/auth/:action/callback
  def all
    @auth = request.env['omniauth.auth']
    @identity = SuperbAuth.identity_class.find_by(provider: @auth.provider, uid: @auth.uid)

    if @identity.present?
      authenticate_with_identity
    else
      authenticate_without_identity
    end
  end
  SuperbAuth.user_class.omniauth_providers.each do |provider|
    alias_method provider, :all
  end

  protected

    # Cases when there is such an identity.
    def authenticate_with_identity
      if user_signed_in?
        # User is already authorized. So, the identity could not be attached to him
        redirect_after_authenticate_with_identity_signed_in
      else
        # User is unauthorized. Authorize him
        flash[:notice] = I18n.t('omniauth_callbacks.all.logged_in')
        sign_in @identity.user
        redirect_after_authenticate_with_identity
      end
    end

    # Cases when there is no such an identity
    def authenticate_without_identity
      if user_signed_in?
        # Create new identity and attach it to current user
        identity = current_user.identities.create!(provider: @auth.provider, uid: @auth.uid, data: @auth.to_hash)
        # Maybe we can retrieve some new data?
        current_user.get_user_info_from_identity(identity, save: true)
        # Sign in user and redirect him to profile
        sign_in current_user
        redirect_after_authenticate_without_identity_signed_id
      else
        # Create new user. Then create new identity and attach it to him
        user = User.from_omniauth(@auth)
        user.skip_confirmation! if user.respond_to?(:skip_confirmation!)
        if user.save
          sign_in user
          redirect_after_authenticate_without_identity_success
        else
          redirect_after_authenticate_without_identity_failure
        end
      end
    end

    def redirect_after_authenticate_with_identity_signed_in
      redirect_to main_app.edit_user_registration_url, alert: I18n.t('omniauth_callbacks.all.identity_alredy_taken')
    end

    def redirect_after_authenticate_with_identity
      redirect_to main_app.root_url
    end

    def redirect_after_authenticate_without_identity_signed_id
      redirect_to main_app.edit_user_registration_url, notice: I18n.t('omniauth_callbacks.all.identity_attached')
    end

    def redirect_after_authenticate_without_identity_success
      redirect_to main_app.root_url, notice: I18n.t('omniauth_callbacks.all.registred_successfully')
    end

    def redirect_after_authenticate_without_identity_failure
      redirect_to main_app.root_url, alert: I18n.t('omniauth_callbacks.all.unknown_error')
    end

end
