class DeterminePokerHandWinnerService
  # 数字が大きいほど強いとする
  HAND_RANKS = {
    'ストレートフラッシュ' =>  8,
    'フォー・オブ・ア・カインド' => 7,
    'フルハウス' => 6,
    'フラッシュ' => 5,
    'ストレート' => 4,
    'スリー・オブ・ア・カインド' => 3,
    'ツーペア' => 2,
    'ワンペア' => 1,
    'ハイカード' => 0
  }.freeze

  def initialize(cards)
    @cards = cards
  end

  def call
    # 勝者を決定する
    determine_poker_hand_winner
  end

  private

  # 勝者を決定する
  def determine_poker_hand_winner
    objects, error_objects = create_hand_result_hash
    sort_objects = objects.sort_by { |obj| -obj[:num]}
    sort_results = sort_objects.each do |object|
                    if object[:hand] == sort_objects.first[:hand]
                      object[:best] = true
                    else
                      object[:best] = false
                    end
                    object.delete(:num)
                  end
    results = sort_results.sort_by { |hash| hash[:index] }
    results.map{|result| result.delete(:index)}
    [results, error_objects]
  end

  # 重複カードがあった場合はそのカードを取り出す
  def select_duplicate_cards
    all_cards = @cards.map { |str| str.split(' ') }.flatten
    unique_cards = all_cards.uniq
    if all_cards.size != unique_cards.size
      all_cards.select { |card| all_cards.count(card) > 1 }.uniq
    end
  end

  # 返却用のハッシュを作る
  def create_hand_result_hash
    objects = []
    error_objects = []
    @cards.each_with_index do |card, index|
      result = DeterminePokerHandService.new(card).call
      if result[:hand_name].present? && select_duplicate_cards.blank?
        # あとで役の強さ順に並べるので、numを持たせておく
        objects << {card: card, hand: result[:hand_name], num: HAND_RANKS[result[:hand_name]], index: index}
      elsif select_duplicate_cards.present?
        error_objects << {card: card, msg: "与えられたカードが重複しています！(#{select_duplicate_cards.join(', ')})"}
      else
        error_objects << {card: card, msg: "#{result[:error]}"}
      end
    end
    [objects, error_objects]
  end
end