Rails.application.routes.draw do
  root 'welcome#index'

  devise_for :users, controllers: { omniauth_callbacks: 'superb_auth/omniauth_callbacks' }
  mount SuperbAuth::Engine => "/superb_auth"
end
