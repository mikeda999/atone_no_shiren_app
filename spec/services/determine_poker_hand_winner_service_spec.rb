require 'rails_helper'

RSpec.describe DeterminePokerHandWinnerService, type: :service do
  describe '#call' do
    let(:service) {DeterminePokerHandWinnerService.new(cards)}

    # フルハウス、ワンペア、 ハイカードになるはずのカードを渡した時、カード情報、役名、優勝フラグを返す
    context 'when give the appropriate three hands' do
      let(:cards) {['H1 H13 H12 H11 D1','H9 C9 S9 H2 C2','C13 D12 C11 H8 H7']}
      let(:determined_hand_name) {[DeterminePokerHandService::ONE_PEAR, DeterminePokerHandService::FULL_HOUSE, DeterminePokerHandService::HIGH_CARD]}

      it 'retuns hash with card, hand_name and best' do
        results, errors = service.call
        results.each_with_index do |result, index|
          expect(result[:card]).to eq cards[index]
          expect(result[:hand]).to eq determined_hand_name[index]
          if index == 1
            expect(result[:best]).to be_truthy
          else
            expect(result[:best]).to be_falsey
          end
        end
      end
    end

    # ワンペア、ワンペア、 ハイカードになる（同じ役名が優勝する）はずのカードを渡した時、カード情報、役名、優勝フラグ(trueは2つ)を返す
    context 'when give the hand names "one pair", "one pair", "high card"' do
      let(:cards) {['H1 H13 H12 H11 D1','C1 C3 S4 S5 S1','C13 D12 C11 H8 H7']}
      let(:determined_hand_name) {[DeterminePokerHandService::ONE_PEAR, DeterminePokerHandService::ONE_PEAR, DeterminePokerHandService::HIGH_CARD]}

      it 'retuns hash with card, hand_name and best' do
        results, errors = service.call
        results.each_with_index do |result, index|
          expect(result[:card]).to eq cards[index]
          expect(result[:hand]).to eq determined_hand_name[index]
          if result[:hand] == results.first[:hand]
            expect(result[:best]).to be_truthy
          else
            expect(result[:best]).to be_falsey
          end
        end
      end
    end

    # 全て同じ役名のカードを渡した時、カード情報、役名、優勝フラグ(trueは3つ)を返す
    context 'when give a hand of cards that all have the same role name' do
      let(:cards) {['H1 H13 H12 H11 D1','C1 C3 S4 S5 S1','C13 D12 S13 H8 H7']}
      let(:determined_hand_name) {DeterminePokerHandService::ONE_PEAR}

      it 'retuns hash with card, hand_name and best' do
        results, errors = service.call
        results.each_with_index do |result, index|
          expect(result[:card]).to eq cards[index]
          expect(result[:hand]).to eq determined_hand_name
          expect(result[:best]).to be_truthy
        end
      end
    end

    # 同じスートと数字の組み合わせのカードが含まれた時、「与えられたカードが重複しています！（[カード情報]）」というエラーが出る
    context 'when give cards of the same suit and number combination are included' do
      let(:cards) {['H1 H13 H12 H11 D1','H1 C3 S4 S5 D1','C13 D12 S13 H8 H7']}

      it 'occurs duplicate error' do
        results, errors = service.call
        expect(results).to be_blank
        errors.each do |error|
          expect(error[:msg]).to eq "与えられたカードが重複しています！(H1, D1)"
        end
      end
    end

    # スートと数字の組み合わせがおかしいカードが含まれる時、それが含まれている手札は「n番目のカード指定文字が不正です（[不正文字]）。」エラーが出る
    context 'when the combination of suits and numbers is inappropriate' do
      let(:cards) {['123 H13 H12 H11 D1','C9 S9 H2 あああ C2','C13 D12 C11 H8 H7']}

      it 'occurs incorrect error' do
        results, errors = service.call
        errors.each_with_index do |error, index|
          if index == 0
            expect(error[:msg]).to eq "1番目のカード指定文字が不正です。（123）"
          elsif index == 1
            expect(error[:msg]).to eq "4番目のカード指定文字が不正です。（あああ）"
          end
        end
      end
    end

    # スートと数字の組み合わせがおかしいカードが含まれる時、適切な手札はカード情報、役名、優勝フラグを返す
    context 'when the combination of suits and numbers is inappropriate' do
      let(:cards) {['123 H13 H12 H11 D1','C9 S9 H2 あああ C2','C13 D12 C11 H8 H7']}
      let(:determined_hand_name) {DeterminePokerHandService::HIGH_CARD}

      it 'retuns hash with card, hand_name and best in the case of a suitable hand' do
        results, errors = service.call
        results.each do |result|
          expect(result[:card]).to eq 'C13 D12 C11 H8 H7'
          expect(result[:hand]).to eq determined_hand_name
          expect(result[:best]).to be_truthy
        end
      end
    end

    # 与えられたカード数が足りない時、該当の手札は「カードは5枚で入力してください」エラーが出る
    context 'when the number of cards given is not enough' do
      let(:cards) {['H11 C1', 'H1 C3 S4 S5 D1','C13 D12 C11 H8 H7']}
      let(:determined_hand_name) {DeterminePokerHandService::HIGH_CARD}

      it 'occurs an error message saying that you need to enter 5 cards' do
        results, errors = service.call
        errors.each do |error|
          expect(error[:msg]).to eq 'カードは5枚で入力してください'
        end
      end
    end

    # 与えられたカード数が足りない時、該当以外の手札はカード情報、役名、優勝フラグを返す
    context 'when the number of cards given is not enough' do
      let(:cards) {['H11 C1', 'H1 C3 S4 S5 D1','C13 D12 C11 H8 H7']}
      let(:determined_hand_name) {[DeterminePokerHandService::ONE_PEAR, DeterminePokerHandService::HIGH_CARD]}

      it 'occurs an error message saying that you need to enter 5 cards' do
        results, errors = service.call
        results.each_with_index do |result, index|
          expect(result[:card]).to eq cards[index + 1]
          expect(result[:hand]).to eq determined_hand_name[index]
          if index == 0
            expect(result[:best]).to be_truthy
          else
            expect(result[:best]).to be_falsey
          end
        end
      end
    end

    # 与えられたカード数が超過している時、該当の手札は「カードは5枚で入力してください」エラーが出る
    context 'when the number of cards given is exceed' do
      let(:cards) {['H9 H13 H12 H11 D13 S13', 'H1 C3 S4 S5 D1','C13 D12 C11 H8 H7']}

      it 'occurs an error message saying that you need to enter 5 cards' do
        results, errors = service.call
        errors.each do |error|
          expect(error[:msg]).to eq 'カードは5枚で入力してください'
        end
      end
    end

    # 与えられたカード数が超過している時、該当以外の手札はカード情報、役名、優勝フラグを返す
    context 'when the number of cards given is exceed' do
      let(:cards) {['H9 H13 H12 H11 D13 S13', 'H1 C3 S4 S5 D1','C13 D12 C11 H8 H7']}
      let(:determined_hand_name) {[DeterminePokerHandService::ONE_PEAR, DeterminePokerHandService::HIGH_CARD]}

      it 'retuns hash with card, hand_name and best in the case of a suitable hand' do
        results, errors = service.call
        results.each_with_index do |result, index|
          expect(result[:card]).to eq cards[index + 1]
          expect(result[:hand]).to eq determined_hand_name[index]
          if index == 0
            expect(result[:best]).to be_truthy
          else
            expect(result[:best]).to be_falsey
          end
        end
      end
    end
  end
end