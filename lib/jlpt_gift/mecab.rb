# frozen_string_literal: true

module JlptGift
  class Mecab
    attr_accessor :surface, :part_of_speech, :part_of_speech_detail1,
                  :part_of_speech_detail2, :part_of_speech_detail3,
                  :inflection_type, :inflection_form, :base_form,
                  :reading, :pronunciation

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

    def to_s
      "#{@surface}\t#{@part_of_speech},#{@part_of_speech_detail1 || "*"},#{@part_of_speech_detail2 || "*"},#{@part_of_speech_detail3 || "*"},#{@inflection_type || "*"},#{@inflection_form || "*"},#{@base_form},#{@reading},#{@pronunciation}"
    end

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

    private

    def convert_asterisk(value)
      value == "*" ? nil : value
    end
  end
end
