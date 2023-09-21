Rails.application.routes.draw do
  # ルートパスはカード入力画面にしておく
  root to: 'cards#new'

  get 'cards/new', to: 'cards#new'
  get 'cards/show_hand', to: 'cards#show_hand'
  post 'cards/show_hand', to: 'cards#show_hand'

  # app/api/api.rbをマウント
  mount API => '/'
end
