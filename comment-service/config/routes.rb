Rails.application.routes.draw do
  resources :comments, only: [:index, :show, :create], defaults: { format: :json } do
    collection do
      get 'by_author/:author_id', to: 'comments#by_author'
    end
  end
end
