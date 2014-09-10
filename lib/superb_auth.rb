require 'devise'
require 'superb_auth/engine'
require 'superb_auth/concerns/omniauthable'
require 'superb_auth/concerns/non_email_authenticable'
require 'superb_auth/concerns/identity'

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
end
