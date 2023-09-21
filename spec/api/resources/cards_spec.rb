require 'rails_helper'

describe "cards api", :type => :request do
  before do
    post "/api/v1/cards", {"cards": ['H1 H13 H12 H11 D1','H9 C9 S9 H2 C2','C13 D12 C11 H8 H7', 'C1, C3, C4, C5, C6']}
  end

  # 手札の組み合わせが全て適切な時
  describe 'when give the appropriate hands' do
    # ステータスコードは200番台
    it "responds successfully" do
      expect(response).to be_success
    end

    # ポーカーの結果を返す
    it "returns result" do
      body = JSON.parse(response.body)
      expect(body["result"]).to be_present
    end

    # エラーは存在しない
    it "returns blank error" do
      body = JSON.parse(response.body)
      expect(body["error"]).to be_nil
    end
  end

  # 不適切な手札が混じっている時
  describe 'when give the inappropriate hands are mixed up' do
    before do
      post "/api/v1/cards", {"cards": ['123 H13 H12 H11 D1','C9 S9 H2 あああ C2','C13 D12 C11 H8 H7']}
    end

    it "responds successfully" do
      expect(response).to be_success
    end

    it "returns result" do
      body = JSON.parse(response.body)
      expect(body["result"]).to be_present
    end

    it "returns error" do
      body = JSON.parse(response.body)
      expect(body["error"]).to be_present
    end
  end

  # 全て不適切な手札の時
  describe 'when give the inappropriate hands' do
    before do
      post "/api/v1/cards", {"cards": ['H1 H13 H12 H11 D1','H1 C3 S4 S5 D1','C13 D12 S13 H8 H7']}
    end

    it "responds successfully" do
      expect(response).to be_success
    end

    it "returns result" do
      body = JSON.parse(response.body)
      expect(body["result"]).to eq []
    end

    it "returns error" do
      body = JSON.parse(response.body)
      expect(body["error"]).to be_present
    end
  end
end