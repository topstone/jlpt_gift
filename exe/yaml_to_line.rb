#!/usr/bin/env ruby
require 'yaml'

# カタカナをひらがなに変換するメソッド
def katakana_to_hiragana(str)
  str.tr('ァ-ヶ', 'ぁ-ゖ')
end

# 標準入力からYAMLデータを読み込み
input = STDIN.read

begin
  # YAMLをパース
  data = YAML.load(input)
  
  # 形態素データを処理
  if data && data['形態素']
    data['形態素'].each do |morpheme|
      # jlpt_levelが定義されている場合のみ処理
      if morpheme[:jlpt_level]
        jlpt_level = morpheme[:jlpt_level]
        base_form = morpheme[:base_form]
        reading = morpheme[:reading]
        
        # 読みをひらがなに変換
        hiragana_reading = katakana_to_hiragana(reading)
        
        # CSV形式で出力
        puts "#{jlpt_level},#{base_form},#{hiragana_reading}"
      end
    end
  end
rescue => e
  STDERR.puts "エラー: #{e.message}"
  exit 1
end