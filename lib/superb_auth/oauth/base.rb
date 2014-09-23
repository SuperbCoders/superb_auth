# Base class for reading info from OmniAuth data
module SuperbAuth
  module OAuth
    class Base
      attr_reader :data

      def initialize(data = {})
        @data = data
      end

      def provider
        data['provider']
      end

      def uid
        data['uid']
      end

      def email
        (data || {}).fetch('info', {}).fetch('email', nil)
      end

      def name
        (data || {}).fetch('info', {}).fetch('name', nil)
      end

      def link
        (data || {}).fetch('info', {}).fetch('urls', {}).fetch(provider.to_s.camelize, nil)
      end

      def avatar
        (data || {}).fetch('info', {}).fetch('image', nil)
      end
    end
  end
end
