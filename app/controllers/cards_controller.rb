class CardsController < ApplicationController
  # 初期表示
  def new
  end

  # カードを判定し、結果を返す。新規画面と共通なのでそこに返す
  # システムエラーが生じた時は、それ用のエラーを返す
  def show_hand
    if request.get?
      redirect_to action: :new
    else
      begin
        @result = DeterminePokerHandService.new(params[:cards]).call
        @card = params[:cards]
        render :new
      rescue => e
        # ログを残す
        Rails.logger.error e.message
        @result = {error: '何らかのエラーが発生しました。詳細はサイト運営にお問い合わせください'}
        render :new
      end
    end
  end
end
