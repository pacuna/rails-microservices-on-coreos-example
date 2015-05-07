Rails.application.routes.draw do
  resources :users, only: [:index, :show, :create], defaults: { format: :json } do
    member do
      get 'comments'
    end
  end
end
