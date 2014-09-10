SuperbAuth::Engine.routes.draw do
  delete 'identities/:provider' => 'identities#destroy', as: :identity
end
