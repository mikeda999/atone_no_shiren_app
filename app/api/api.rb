class API < Grape::API
  # 全てのバージョンに共通する設定
  prefix 'api'
  mount Resources::V1::Root
end