require 'rails_helper'

RSpec.describe CardsController, type: :controller do
  # newアクション
  describe '#new' do
    before :each do
      get :new
    end

    # 正常なレスポンスが返ってくるか
    it 'responds successfully' do
      expect(response).to be_success
    end
    # 200レスポンスが返ってくるか
    it 'returns a 200 response' do
      expect(response).to have_http_status "200"
    end
  end

  # show_handアクション
  describe '#show_hand' do
    # 正常なレスポンスが返ってくるか
    it 'responds successfully' do
      post :show_hand, cards: 'H1 C1 S10 D9 C3'
      expect(response).to be_success
    end

    # 200レスポンスが返ってくるか
    it 'returns a 200 response' do
      post :show_hand, cards: 'H1 C1 S10 D9 C3'
      expect(response).to have_http_status '200'
    end

    # new actionにredirectする
    it 'responds successfully' do
      get :show_hand
      expect(response).to redirect_to action: :new
    end
    # 302レスポンスが返ってくる
    it 'returns a 200 response' do
      get :show_hand
      expect(response).to have_http_status "302"
    end
  end
end