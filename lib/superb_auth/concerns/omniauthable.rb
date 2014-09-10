module SuperbAuth
  module Concerns
    module Omniauthable
      extend ActiveSupport::Concern

      included do
        @allowed_oauth_attributes = %w(email)

        has_many SuperbAuth.identity_class_name.underscore.pluralize.to_sym, dependent: :destroy, inverse_of: SuperbAuth.user_class_name.underscore.to_sym

        omniauth_providers.each do |provider|
          define_method provider do
            identity = instance_variable_get("@#{provider}")
            unless identity
              identity = identities.select { |i| i.provider.to_s == provider.to_s }.first
              instance_variable_set("@#{provider}", identity)
            end
            identity
          end
        end
      end

      # Tries to get some new user info from identity
      # @param identity [Identity] identiy
      def get_user_info_from_identity(identity, options = { save: false })
        # self.remote_avatar_url = identity.avatar if !avatar? && identity.avatar
        # self.name = identity.name unless name.present?
        # save if options[:save] && (remote_avatar_url.present? || name_changed?)
      end

      module ClassMethods
        def from_omniauth(auth)
          user = if omniauth_providers.include?(auth.provider)
            send("from_#{auth.provider}_omniauth", auth)
          else
            raise 'UnknownProvider'
          end
          identity = user.identities.build(provider: auth.provider, uid: auth.uid, data: auth.to_hash)
          user.get_user_info_from_identity(identity)
          user
        end

        def from_facebook_omniauth(auth)
          options = allowed_options({ name: auth.info.name })
          if auth.info.email.present?
            where(email: auth.info.email).first_or_initialize(options)
          else
            new(options)
          end
        end

        def from_vkontakte_omniauth(auth)
          options = allowed_options({ name: auth.info.name })
          if auth.info.email.present?
            where(email: auth.info.email).first_or_initialize(options)
          else
            new(options)
          end
        end

        def from_twitter_omniauth(auth)
          new(allowed_options({name: auth.info.name}))
        end

        def allowed_options(options)
          options.select { |k, v| @allowed_oauth_attributes.include?(k.to_s) }
        end
      end
    end
  end
end
