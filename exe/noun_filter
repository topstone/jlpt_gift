#!/usr/bin/env ruby
require 'yaml'

# 標準入力からYAMLデータを読み込み
input_data = YAML.load(STDIN.read)

# 算用数字や漢数字のみかどうかを判定する関数
def numeric_only?(text)
  # 算用数字のみ
  return true if text.match?(/\A\d+\z/)
  
  # 漢数字のみ（一、二、三、四、五、六、七、八、九、十、百、千、万、億、兆など）
  return true if text.match?(/\A[一二三四五六七八九十百千万億兆〇零]+\z/)
  
  false
end

# 条件に合致する形態素を抽出
filtered_morphemes = input_data['形態素'].select do |morpheme|
  # 条件1: part_of_speechが名詞
  next false unless morpheme[:part_of_speech] == '名詞'
  
  # 条件2: part_of_speech_detail1が代名詞以外
  next false if morpheme[:part_of_speech_detail1] == '代名詞'
  
  # 条件3: 算用数字や漢数字だけのものは除外
  next false if numeric_only?(morpheme[:surface])
  
  true
end

# 結果をYAML形式で出力
result = { '形態素' => filtered_morphemes }
puts YAML.dump(result, line_width: -1)
