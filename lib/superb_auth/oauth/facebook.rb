# Facebook adapter for reading OmniAuth data
module SuperbAuth
  module OAuth
    class Facebook < SuperbAuth::OAuth::Base
      def avatar
        avatar = super
        avatar = process_uri(avatar) if avatar
        avatar
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
