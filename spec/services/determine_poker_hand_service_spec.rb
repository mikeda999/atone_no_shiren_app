require 'rails_helper'

RSpec.describe DeterminePokerHandService, type: :service do
  describe '#call' do
    let(:service) {DeterminePokerHandService.new(cards)}

    # ストレートフラッシュの時、「ストレートフラッシュ」、エラーは空と返す
    # ストレートフラッシュ：同じスートで数字が連続する5枚のカード
    context 'when give a straight flush' do
      let(:cards) { 'H2 H1 H5 H3 H4' }

      it 'returns "ストレートフラッシュ"' do
        expect(service.call[:hand_name]).to eq DeterminePokerHandService::STRAIGHT_FLUSH
      end

      it 'error is blank' do
        expect(service.call[:error]).to be_blank
      end
    end

    # ストレートフラッシュ([1, 10, 11, 12, 13])の時、「ストレートフラッシュ」、エラーは空と返す
    # ストレートフラッシュ：同じスートで数字が連続する5枚のカード
    context 'when give a straight flush' do
      let(:cards) { 'H1 H13 H12 H11 H10' }

      it 'returns "ストレートフラッシュ"' do
        expect(service.call[:hand_name]).to eq DeterminePokerHandService::STRAIGHT_FLUSH
      end

      it 'error is blank' do
        expect(service.call[:error]).to be_blank
      end
    end

    # フォー・オブ・ア・カインドの時、「フォー・オブ・ア・カインド」、エラーは空と返す
    # フォー・オブ・ア・カインド：同じ数字のカード4枚が含まれる
    context 'when give a four of a kind' do
      let(:cards) { 'H2 S2 H5 D2 C2' }

      it 'returns "フォー・オブ・ア・カインド"' do
        expect(service.call[:hand_name]).to eq DeterminePokerHandService::FOUR_OF_A_KIND
      end

      it 'error is blank' do
        expect(service.call[:error]).to be_blank
      end
    end

    # フルハウスの時、「フルハウス」、エラーは空と返す
    # フルハウス：同じ数字のカード3枚と、別の同じ数字のカード2枚
    context 'when give a full house' do
      let(:cards) { 'H2 S2 H12 D12 C2' }

      it 'returns "フルハウス"' do
        expect(service.call[:hand_name]).to eq DeterminePokerHandService::FULL_HOUSE
      end

      it 'error is blank' do
        expect(service.call[:error]).to be_blank
      end
    end

    # フラッシュの時、「フラッシュ」、エラーは空と返す
    # フラッシュ：同じスートのカード5枚
    context 'when give a flush' do
      let(:cards) { 'H2 H6 H12 H8 H11' }

      it 'returns "フラッシュ"' do
        expect(service.call[:hand_name]).to eq DeterminePokerHandService::FLUSH
      end

      it 'error is blank' do
        expect(service.call[:error]).to be_blank
      end
    end

    # ストレートの時、「ストレート」、エラーは空と返す
    # ストレート：連続した数字5枚のカード
    context 'when give a straight' do
      let(:cards) { 'H2 D6 S5 H3 C4' }

      it 'returns "ストレート"' do
        expect(service.call[:hand_name]).to eq DeterminePokerHandService::STRAIGHT
      end

      it 'error is blank' do
        expect(service.call[:error]).to be_blank
      end
    end

    # スリー・オブ・ア・カインドの時、「スリー・オブ・ア・カインド」、エラーは空と返す
    # スリー・オブ・ア・カインド：同じ数字のカード3枚と異なる数字のカード2枚
    context 'when give a three of a kind' do
      let(:cards) { 'H2 D2 S2 H10 C13' }

      it 'returns "スリー・オブ・ア・カインド"' do
        expect(service.call[:hand_name]).to eq DeterminePokerHandService::THREE_OF_A_KIND
      end

      it 'error is blank' do
        expect(service.call[:error]).to be_blank
      end
    end

    # ツーペアの時、「ツーペア」、エラーは空と返す
    # ツーペア：同じ数字のカード2枚組を2組と他のカード1枚
    context 'when give a two pear' do
      let(:cards) { 'H2 D2 S10 H13 C13' }

      it 'returns "ツーペア"' do
        expect(service.call[:hand_name]).to eq DeterminePokerHandService::TWO_PEAR
      end

      it 'error is blank' do
        expect(service.call[:error]).to be_blank
      end
    end

    # ワンペアの時、「ワンペア」、エラーは空と返す
    # ワンペア：同じ数字のカード2枚と異なる数字のカード3枚
    context 'when give a one pear' do
      let(:cards) { 'H2 D2 S10 H9 C13' }

      it 'returns "ワンペア"' do
        expect(service.call[:hand_name]).to eq DeterminePokerHandService::ONE_PEAR
      end

      it 'error is blank' do
        expect(service.call[:error]).to be_blank
      end
    end

    # 上記に当てはまらない時、渡されたカードデータが適切であれば「ハイカード」、エラーは空と返す
    context "when the data passed id appropriate and don't have apoker hand" do
      let(:cards) { 'H2 D4 S10 H9 C13' }

      it 'returns "ハイカード"' do
        expect(service.call[:hand_name]).to eq DeterminePokerHandService::HIGH_CARD
      end

      it 'error is blank' do
        expect(service.call[:error]).to be_blank
      end
    end

    # 渡されたカードが5枚より多い時、「カードは5枚で入力してください」というエラー、役名は空を返す
    context "when the number of cards passed is more than 5" do
      let(:cards) { 'H2 D4 S10 H9 C13 D1' }

      it 'returns "カードは5枚で入力してください"' do
        expect(service.call[:error]).to eq 'カードは5枚で入力してください'
      end

      it 'hand_name is blank' do
        expect(service.call[:hand_name]).to be_blank
      end
    end

    # 渡されたカードが5枚より少ない時、「カードは5枚で入力してください」というエラー、役名は空を返す
    context 'when the number of cards passed is more than 5' do
      let(:cards) { 'H2 C13 D1' }

      it 'returns "カードは5枚で入力してください"' do
        expect(service.call[:error]).to eq 'カードは5枚で入力してください'
      end

      it 'hand_name is blank' do
        expect(service.call[:hand_name]).to be_blank
      end
    end

    # 渡されたカードのスートと数字が適切でない時、「5番目のカード指定文字が不正です。（K2）」というエラーを返す、役名は空
    context 'when the suit and rank of the card passed is not appropriate' do
      let(:cards) { 'H2 C13 D1 C9 K2' }

      it 'returns "渡されたカード情報が誤っています。もう一度、入力してください"' do
        expect(service.call[:error]).to eq '5番目のカード指定文字が不正です。（K2）'
      end

      it 'hand_name is blank' do
        expect(service.call[:hand_name]).to be_blank
      end
    end

    # カードのスートと数字の組み合わせが重複している時、「カードは重複せずに、入力してください」というエラーを返す、役名は空
    context 'when there is a duplicate combination of suits and numbers on a card' do
      let(:cards) { 'H2 C13 D1 C9 H2' }

      it 'returns "カードは重複せずに、入力してください"' do
        expect(service.call[:error]).to eq 'カードは重複せずに、入力してください'
      end

      it 'hand_name is blank' do
        expect(service.call[:hand_name]).to be_blank
      end
    end
  end
end