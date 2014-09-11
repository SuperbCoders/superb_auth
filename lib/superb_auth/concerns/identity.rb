module SuperbAuth
  module Concerns
    module Identity
      extend ActiveSupport::Concern

      included do
        belongs_to SuperbAuth.user_class_name.underscore.to_sym, inverse_of: SuperbAuth.identity_class_name.underscore.pluralize.to_sym

        validates SuperbAuth.user_class_name.underscore.to_sym, presence: true
        validates :provider, presence: true, inclusion: { in: SuperbAuth.user_class.omniauth_providers.map(&:to_s) }
        validates :uid, presence: true
        validates "#{SuperbAuth.user_class_name.underscore}_id".to_sym, uniqueness: { scope: :provider }
        validates :uid, uniqueness: { scope: :provider }

        serialize :data
        delegate :email, :name, :avatar, :link, to: :oauth_adapter
      end

      private

        # @return [SuperbAuth::OAuth::Base] adapter for reading info from raw OAuth data
        def oauth_adapter
          SuperbAuth.adapter_for(data)
        end

    end
  end
end
