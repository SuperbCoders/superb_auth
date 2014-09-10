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
      end

      def link
        case provider
        when 'facebook' then (data || {}).fetch('info', {}).fetch('urls', {}).fetch('Facebook', nil)
        when 'vkontakte' then (data || {}).fetch('info', {}).fetch('urls', {}).fetch('Vkontakte', nil)
        when 'twitter' then (data || {}).fetch('info', {}).fetch('urls', {}).fetch('Twitter', nil)
        else nil
        end
      end

      def avatar
        avatar = (data || {}).fetch('info', {}).fetch('image', nil)
        avatar = avatar.gsub('_normal.', '.') if avatar && provider == 'twitter'
        avatar = process_uri(avatar) if avatar && provider == 'facebook'
        avatar
      end

      def name
        (data || {}).fetch('info', {}).fetch('name', nil)
      end

      private

        def process_uri(uri)
          require 'open-uri'
          require 'open_uri_redirections'
          open(uri, allow_redirections: :safe) do |r|
            r.base_uri.to_s
          end
        end

    end
  end
end