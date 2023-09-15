class DeterminePokerHandService
  # カードのスートは不変なので定数化しておく
  CARD_SUITS = ['S','H','D','C'].freeze
  # ポーカーにおいて渡されるカードが5枚であることは不変なので定数化しておく
  FIVE_CARDS = 5.freeze
  # 役名は不変なので定数化しておく
  # ストレートフラッシュ
  STRAIGHT_FLUSH = 'ストレートフラッシュ'.freeze
  FOUR_OF_A_KIND = 'フォー・オブ・ア・カインド'.freeze
  FULL_HOUSE = 'フルハウス'.freeze
  FLUSH = 'フラッシュ'.freeze
  STRAIGHT = 'ストレート'.freeze
  THREE_OF_A_KIND = 'スリー・オブ・ア・カインド'.freeze
  TWO_PEAR = 'ツーペア'.freeze
  ONE_PEAR = 'ワンペア'.freeze
  HIGH_CARD = 'ハイカード'.freeze

  # インスタンス化した時の初期処理
  def initialize(cards)
    # カードは半角空白で区切って5枚渡されるはずなので、半角空白で分けてハッシュ形式で持たせる
    @cards = cards.split(' ').map do |card|
                if card.match(/([A-Z]+)(\d+)/).present?
                  {suit: card.match(/([A-Z]+)(\d+)/)[1], rank: card.match(/([A-Z]+)(\d+)/)[2]}
                end
             end
  end


  def call
    determine_poker_hand
  end

  private


  # 役の決定
  # 上から順に強い
  def determine_poker_hand
    # カードが5枚あるか、重複しているカードはないか、正しいスートと数字の組み合わせかを判定
    # 間違っていた場合は
    # メモ：エラーハンドリングを考える
    return {hand_name: '', error: 'カードは5枚で入力してください'} unless five_cards?
    return {hand_name: '', error: '渡されたカード情報が誤っています。もう一度、入力してください' } unless correct_cards_set?
    return {hand_name: '', error: 'カードは重複せずに、入力してください' } unless unique_five_cards?


    if straight_flush?
      {hand_name: STRAIGHT_FLUSH}
    elsif four_of_a_kind?
      {hand_name: FOUR_OF_A_KIND}
    elsif full_house?
      {hand_name: FULL_HOUSE}
    elsif flush?
      {hand_name: FLUSH}
    elsif straight?
      {hand_name: STRAIGHT}
    elsif three_of_a_kind?
      {hand_name: THREE_OF_A_KIND}
    elsif two_pear?
      {hand_name: TWO_PEAR}
    elsif one_pear?
      {hand_name: ONE_PEAR}
    else
      {hand_name: HIGH_CARD}
    end
  end

  # -------------------- 以下は、入力された値が正しいかを判定するロジック ------------
  # 渡されたカードが5枚であるかの判定(nilは除く)
  def five_cards?
    @cards.compact.length == FIVE_CARDS
  end

  # スートがS,H,D,Cのいずれか、数字が1-13のいずれかの組み合わせになっているかの判定
  # 5枚全てのカードの組み合わせが正しい時true、それ以外はfalseを返す
  def correct_cards_set?
    @cards.map{ |card| CARD_SUITS.include?(card[:suit]) && card[:rank] =~ /^(1[0-3]|[1-9])$/ }.all?
  end

  # カードのスートと数字の組み合わせが重複していないかの判定
  def unique_five_cards?
    @cards.map{ |card| (card[:suit] + card[:rank]) }.uniq.length == 5
  end


  # --------------------------- 以下は、役のロジック -----------------------------

  # ストレートフラッシュの判定
  # 同じスートで数字が連続する5枚のカード
  def straight_flush?
    straight? && flush?
  end

  # フォー・オブ・ア・カインドの判定
  # 同じ数字のカード4枚が含まれる
  def four_of_a_kind?
    ranks = pluck_rank_from_card
    same_rank?(ranks, 4)
  end

  # フルハウスの判定
  # 同じ数字のカード3枚と、別の同じ数字のカード2枚
  def full_house?
    ranks = pluck_rank_from_card
    same_rank?(ranks, 3) && same_rank?(ranks, 2)
  end

  # フラッシュの判定
  # 同じスートのカード5枚
  def flush?
    all_same_suit?
  end

  # ストレートの判定
  # 連続した数字5枚のカード
  def straight?
    consecutive_rank?
  end

  # スリー・オブ・ア・カインドの判定
  # 同じ数字のカード3枚と異なる数字のカード2枚
  def three_of_a_kind?
    ranks = pluck_rank_from_card
    same_rank?(ranks, 3) && ranks.uniq.length == 3
  end

  # ツーペアの判定
  # 同じ数字のカード2枚組を2組と他のカード1枚
  def two_pear?
    ranks = pluck_rank_from_card
    same_rank?(ranks, 2) && ranks.uniq.length == 3
  end

  # ワンペアの判定
  # 同じ数字のカード2枚と異なる数字のカード3枚
  def one_pear?
    ranks = pluck_rank_from_card
    same_rank?(ranks, 2) && ranks.uniq.length == 4
  end

  # ----------------- 以下は、役に当てはまるかの判定のためのロジック -----------------
  # 全てのカードが同じスートかどうかを判定する
  def all_same_suit?
    suits = pluck_suit_from_card
    suits.uniq.length == 1
  end

  # 連続する数字かどうかを判定する
  # カード数字順にソートして、最大値と最小値の差が4かつ配列に5つの異なる数字があるかどうか
  def consecutive_rank?
    ranks = pluck_rank_from_card.sort
    (ranks.last.to_i - ranks.first.to_i) == 4 && ranks.uniq.length == 5
  end

  # ----------------- 以下は、共通処理を切り出したもの -----------------
  # スートを配列として取り出す
  # メモ：ここのメソッド名は要確認
  def pluck_suit_from_card
    @cards.map { |card| card[:suit] }
  end

  # 数字(rank)を配列として取り出す
  # メモ：ここのメソッド名は要確認
  def pluck_rank_from_card
    @cards.map { |card| card[:rank] }
  end

  # 渡された枚数(n)について、同じ数字(rank)のカードかどうかを判定する
  def same_rank?(ranks, n)
    ranks.any? { |rank| ranks.count(rank) == n }
  end
end
