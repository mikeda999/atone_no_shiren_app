module Resources
  module V1
    class Cards < Grape::API

      # 渡されたJSONのうち、カード情報を取り出して勝者を決定する
      resource :cards do
        desc 'Return cards and hands and best'
        params do
          # 必須項目（cards）
          requires :cards, type: Array
        end
        post do
          results, errors = DeterminePokerHandWinnerService.new(params[:cards]).call
          if errors.blank?
          # エラーがない場合は、resultsだけ返却
            present :result, results
          else
          # エラーがある場合は、results, errorsの両方を返却
            present :result, results
            present :error, errors
          end
        end
      end
    end
  end
end