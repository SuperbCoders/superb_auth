module SuperbAuth
  module Concerns
    module NonEmailAuthenticable
      extend ActiveSupport::Concern

      # @return [Boolean] whether password is required
      def password_required?
        (identities.empty? || password.present?) && super
      end

      # @return [Boolean] whether email is required
      def email_required?
        identities.empty? && super
      end
    end
  end
end