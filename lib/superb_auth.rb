require 'devise'
require 'superb_auth/engine'

require 'superb_auth/concerns/omniauthable'
require 'superb_auth/concerns/non_email_authenticable'
require 'superb_auth/concerns/identity'

require 'superb_auth/oauth/base'
require 'superb_auth/oauth/facebook'
require 'superb_auth/oauth/vkontakte'
require 'superb_auth/oauth/twitter'

module SuperbAuth
  mattr_accessor :user_class_name
  mattr_accessor :identity_class_name

  self.user_class_name = 'User'
  self.identity_class_name = 'Identity'

  def self.user_class
    @user_class ||= self.user_class_name.constantize
  end

  def self.identity_class
    @identity_class ||= self.identity_class_name.constantize
  end

  # @param data [Hash] raw OmniAuth data from request.env['omniauth.auth']
  # @return [SuperbAuth::OAuth::Base] adapter for reading info from raw OAuth data
  def self.adapter_for(data)
    case data['provider']
    when 'facebook' then SuperbAuth::OAuth::Facebook.new(data)
    when 'vkontakte' then SuperbAuth::OAuth::Vkontakte.new(data)
    when 'twitter' then SuperbAuth::OAuth::Twitter.new(data)
    else SuperbAuth::OAuth::Base.new(data)
    end
  end
end
