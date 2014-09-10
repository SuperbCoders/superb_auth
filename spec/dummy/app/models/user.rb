class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: %w(facebook vkontakte twitter)
  include SuperbAuth::Concerns::Omniauthable
  include SuperbAuth::Concerns::NonEmailAuthenticable
end
