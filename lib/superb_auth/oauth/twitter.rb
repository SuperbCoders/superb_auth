# Twitter adapter for reading OmniAuth data
module SuperbAuth
  module OAuth
    class Twitter < SuperbAuth::OAuth::Base
      def avatar
        avatar = super
        avatar = avatar.gsub('_normal.', '.') if avatar
        avatar
      end
    end
  end
end
