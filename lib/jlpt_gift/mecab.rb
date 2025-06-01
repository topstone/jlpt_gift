# frozen_string_literal: true

require "yaml"

module JlptGift
  # MeCabの出力を解析して構造化データとして扱うためのクラス
  #
  # MeCabの標準出力形式（ChaSen互換形式）をパースし、各フィールドを
  # アクセス可能な属性として提供します。
  #
  # @example 基本的な使用方法
  #   mecab = JlptGift::Mecab.new
  #   mecab.parse("走っ\t動詞,自立,*,*,五段・ラ行,連用タ接続,走る,ハシッ,ハシッ")
  #   puts mecab.surface           # => "走っ"
  #   puts mecab.part_of_speech    # => "動詞"
  #   puts mecab.base_form         # => "走る"
  #
  # @author JLPT Gift Development Team
  # @since 1.0.0
  class Mecab
    # @!attribute [rw] surface
    #   @return [String, nil] 表層形（入力テキストに現れる実際の単語形）
    # @!attribute [rw] part_of_speech
    #   @return [String, nil] 品詞（名詞、動詞、形容詞など）
    # @!attribute [rw] part_of_speech_detail1
    #   @return [String, nil] 品詞細分類1（一般、固有名詞、代名詞など）
    # @!attribute [rw] part_of_speech_detail2
    #   @return [String, nil] 品詞細分類2（人名、地域など）
    # @!attribute [rw] part_of_speech_detail3
    #   @return [String, nil] 品詞細分類3（最も詳細な分類）
    # @!attribute [rw] inflection_type
    #   @return [String, nil] 活用型（五段、一段など）
    # @!attribute [rw] inflection_form
    #   @return [String, nil] 活用形（基本形、過去形など）
    # @!attribute [rw] base_form
    #   @return [String, nil] 原形（辞書形・基本形）
    # @!attribute [rw] reading
    #   @return [String, nil] 読み（カタカナ表記）
    # @!attribute [rw] pronunciation
    #   @return [String, nil] 発音（実際の発音、音韻変化を反映）
    attr_accessor :surface, :part_of_speech, :part_of_speech_detail1,
                  :part_of_speech_detail2, :part_of_speech_detail3,
                  :inflection_type, :inflection_form, :base_form,
                  :reading, :pronunciation

    # Mecabインスタンスを初期化する
    #
    # 全ての属性をnilで初期化します。parseメソッドを呼び出すことで
    # 実際の値が設定されます。
    #
    # @return [JlptGift::Mecab] 新しいMecabインスタンス
    def initialize
      @surface = nil
      @part_of_speech = nil
      @part_of_speech_detail1 = nil
      @part_of_speech_detail2 = nil
      @part_of_speech_detail3 = nil
      @inflection_type = nil
      @inflection_form = nil
      @base_form = nil
      @reading = nil
      @pronunciation = nil
    end

    # MeCabの出力行を解析してインスタンスの属性に設定する
    #
    # MeCabの標準出力形式（表層形\t品詞情報）をパースし、各フィールドを
    # 対応する属性に設定します。品詞情報内の '*' は nil に変換されます。
    #
    # @param str [String, nil] MeCabの出力行文字列
    # @return [void]
    #
    # @example 動詞の解析
    #   mecab.parse("走っ\t動詞,自立,*,*,五段・ラ行,連用タ接続,走る,ハシッ,ハシッ")
    #
    # @example 助動詞の解析
    #   mecab.parse("た\t助動詞,*,*,*,特殊・タ,基本形,た,タ,タ")
    #
    # @note 空文字列、nil、不正な形式の入力は無視されます
    # @note フィールド数が不足している場合、該当する属性はnilのままになります
    def parse(str)
      # 空文字列や nil の場合は何もしない
      return if str.nil? || str.strip.empty?

      # タブで分割
      parts = str.split("\t")
      return if parts.length < 2

      @surface = parts[0]

      # カンマで分割して品詞情報を取得
      features = parts[1].split(",")

      @part_of_speech = features[0] if features.length.positive?
      @part_of_speech_detail1 = convert_asterisk(features[1]) if features.length > 1
      @part_of_speech_detail2 = convert_asterisk(features[2]) if features.length > 2
      @part_of_speech_detail3 = convert_asterisk(features[3]) if features.length > 3
      @inflection_type = convert_asterisk(features[4]) if features.length > 4
      @inflection_form = convert_asterisk(features[5]) if features.length > 5
      @base_form = features[6] if features.length > 6
      @reading = features[7] if features.length > 7
      @pronunciation = features[8] if features.length > 8
    end

    # MeCab出力形式の文字列として返す
    #
    # インスタンスの属性値をMeCabの標準出力形式に整形して返します。
    # nil値は '*' として出力されます。
    #
    # @return [String] MeCab出力形式の文字列
    #
    # @example
    #   mecab.to_s
    #   # => "走っ\t動詞,自立,*,*,五段・ラ行,連用タ接続,走る,ハシッ,ハシッ"
    def to_s
      "#{@surface}\t#{@part_of_speech},#{@part_of_speech_detail1 || "*"},#{@part_of_speech_detail2 || "*"},#{@part_of_speech_detail3 || "*"},#{@inflection_type || "*"},#{@inflection_form || "*"},#{@base_form},#{@reading},#{@pronunciation}"
    end

    # ハッシュ形式で属性値を返す
    #
    # 全ての属性をシンボルキーとするハッシュとして返します。
    # JSON変換やAPIレスポンスの生成などに便利です。
    #
    # @return [Hash<Symbol, String>] 属性名をキー、属性値を値とするハッシュ
    #
    # @example
    #   mecab.to_hash
    #   # => {
    #   #   surface: "走っ",
    #   #   part_of_speech: "動詞",
    #   #   part_of_speech_detail1: "自立",
    #   #   part_of_speech_detail2: nil,
    #   #   ...
    #   # }
    def to_hash
      {
        surface: @surface,
        part_of_speech: @part_of_speech,
        part_of_speech_detail1: @part_of_speech_detail1,
        part_of_speech_detail2: @part_of_speech_detail2,
        part_of_speech_detail3: @part_of_speech_detail3,
        inflection_type: @inflection_type,
        inflection_form: @inflection_form,
        base_form: @base_form,
        reading: @reading,
        pronunciation: @pronunciation
      }
    end

    # 属性をYAML形式で標準出力に出力する
    #
    # インスタンスの全属性をYAML形式で標準出力に出力します。
    # デバッグやログ出力に便利です。
    #
    # @return [void]
    #
    # @example
    #   mecab.put_yaml
    #   # => ---
    #   # surface: 走っ
    #   # part_of_speech: 動詞
    #   # part_of_speech_detail1: 自立
    #   # part_of_speech_detail2:
    #   # part_of_speech_detail3:
    #   # inflection_type: 五段・ラ行
    #   # inflection_form: 連用タ接続
    #   # base_form: 走る
    #   # reading: ハシッ
    #   # pronunciation: ハシッ
    def put_yaml
      puts to_hash.to_yaml
    end

    private

    # アスタリスク文字をnilに変換する
    #
    # MeCabでは未設定や該当なしの値を '*' で表現するため、
    # より扱いやすいようにnilに変換します。
    #
    # @param value [String, nil] 変換対象の値
    # @return [String, nil] '*'の場合はnil、それ以外はそのまま返す
    #
    # @example
    #   convert_asterisk("*")     # => nil
    #   convert_asterisk("自立")  # => "自立"
    #   convert_asterisk(nil)    # => nil
    def convert_asterisk(value)
      value == "*" ? nil : value
    end
  end
end
