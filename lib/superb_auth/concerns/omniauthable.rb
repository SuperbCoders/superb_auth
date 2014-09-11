module SuperbAuth
  module Concerns
    module Omniauthable
      extend ActiveSupport::Concern

      included do
        @oauth_attributes = {}

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
      # @param options [Hash] options
      # @option options [Boolean] :save whether record should be saved when any changes were applied
      # @return [Array<Symbol>] attributes that were updated from OmniAuth data
      def get_user_info_from_identity(identity, options = { save: false })
        updated_attributes = []
        self.class.instance_variable_get(:@oauth_attributes).each do |attribute, options|
          assign_to = options[:assign_to] || attribute
          condition = options[:if] || -> (user) { user.send(assign_to).blank? }
          new_value = identity.send(attribute)
          if new_value.present? && condition.call(self)
            send("#{assign_to}=", new_value)
            updated_attributes << attribute
          end
        end
        save if options[:save] && updated_attributes.any?
        updated_attributes
      end

      module ClassMethods

        # Setup attribute that should be retrieved from OmniAuth
        # @param attribute [Symbol] OmniAuth attribute (full list in SuperbAuth::OAuth::Base adapters)
        # @param options [Hash] special rules
        # @option options [Symbol] :assign_to attribute that will be assigned to the value from OmniAuth.
        #   By default: the same as `attribute`
        # @option options [Proc] :if when it should be assigned
        #   By default: when it is #blank?
        def oauth_attr(attribute, options = {})
          raise 'condition should be a Proc' if options[:if].present? && !options[:if].is_a?(Proc)
          raise 'condition should have 1 argument' if options[:if].present? && options[:if].arity != 1
          @oauth_attributes[attribute.to_sym] = options
        end

        # Builds new user instance from OmniAuth data
        # @params auth [Hash] OmniAuth data
        # @return [User] new user
        def from_omniauth(auth)
          raise 'UnknownProvider' unless omniauth_providers.include?(auth.provider)
          adapter = SuperbAuth.adapter_for(auth.to_hash)
          user = init_by_email(adapter.email)
          identity = user.identities.build(provider: auth.provider, uid: auth.uid, data: auth.to_hash)
          user.get_user_info_from_identity(identity)
          user
        end

        # Looks for the user with the same email or initializes a new one
        # @param email [String]
        # @return [User] found or new user
        def init_by_email(email)
          if email.present?
            where(email: email).first_or_initialize
          else
            new
          end
        end
      end
    end
  end
end
