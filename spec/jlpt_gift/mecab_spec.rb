# frozen_string_literal: true

require "yaml"

RSpec.describe JlptGift::Mecab do
  describe "#initialize" do
    it "initializes all attributes to nil" do
      mecab = described_class.new

      expect(mecab.surface).to be_nil
      expect(mecab.part_of_speech).to be_nil
      expect(mecab.part_of_speech_detail1).to be_nil
      expect(mecab.part_of_speech_detail2).to be_nil
      expect(mecab.part_of_speech_detail3).to be_nil
      expect(mecab.inflection_type).to be_nil
      expect(mecab.inflection_form).to be_nil
      expect(mecab.base_form).to be_nil
      expect(mecab.reading).to be_nil
      expect(mecab.pronunciation).to be_nil
    end
  end

  describe "#parse" do
    context "when parsing a verb" do
      it "correctly parses a verb with all fields" do
        mecab = described_class.new
        mecab.parse("走っ\t動詞,自立,*,*,五段・ラ行,連用タ接続,走る,ハシッ,ハシッ")

        expect(mecab.surface).to eq("走っ")
        expect(mecab.part_of_speech).to eq("動詞")
        expect(mecab.part_of_speech_detail1).to eq("自立")
        expect(mecab.part_of_speech_detail2).to be_nil
        expect(mecab.part_of_speech_detail3).to be_nil
        expect(mecab.inflection_type).to eq("五段・ラ行")
        expect(mecab.inflection_form).to eq("連用タ接続")
        expect(mecab.base_form).to eq("走る")
        expect(mecab.reading).to eq("ハシッ")
        expect(mecab.pronunciation).to eq("ハシッ")
      end
    end

    context "when parsing an auxiliary verb" do
      it "correctly parses an auxiliary verb" do
        mecab = described_class.new
        mecab.parse("た\t助動詞,*,*,*,特殊・タ,基本形,た,タ,タ")

        expect(mecab.surface).to eq("た")
        expect(mecab.part_of_speech).to eq("助動詞")
        expect(mecab.part_of_speech_detail1).to be_nil
        expect(mecab.part_of_speech_detail2).to be_nil
        expect(mecab.part_of_speech_detail3).to be_nil
        expect(mecab.inflection_type).to eq("特殊・タ")
        expect(mecab.inflection_form).to eq("基本形")
        expect(mecab.base_form).to eq("た")
        expect(mecab.reading).to eq("タ")
        expect(mecab.pronunciation).to eq("タ")
      end
    end

    context "when parsing a punctuation mark" do
      it "correctly parses a punctuation mark" do
        mecab = described_class.new
        mecab.parse("。\t記号,句点,*,*,*,*,。,。,。")

        expect(mecab.surface).to eq("。")
        expect(mecab.part_of_speech).to eq("記号")
        expect(mecab.part_of_speech_detail1).to eq("句点")
        expect(mecab.part_of_speech_detail2).to be_nil
        expect(mecab.part_of_speech_detail3).to be_nil
        expect(mecab.inflection_type).to be_nil
        expect(mecab.inflection_form).to be_nil
        expect(mecab.base_form).to eq("。")
        expect(mecab.reading).to eq("。")
        expect(mecab.pronunciation).to eq("。")
      end
    end

    context "when parsing edge cases" do
      it "handles empty string" do
        mecab = described_class.new
        mecab.parse("")

        expect(mecab.surface).to be_nil
      end

      it "handles nil input" do
        mecab = described_class.new
        mecab.parse(nil)

        expect(mecab.surface).to be_nil
      end

      it "handles string with only whitespace" do
        mecab = described_class.new
        mecab.parse("   ")

        expect(mecab.surface).to be_nil
      end

      it "handles malformed input without tab" do
        mecab = described_class.new
        mecab.parse("走る動詞")

        expect(mecab.surface).to be_nil
      end

      it "handles input with insufficient features" do
        mecab = described_class.new
        mecab.parse("走る\t動詞")

        expect(mecab.surface).to eq("走る")
        expect(mecab.part_of_speech).to eq("動詞")
        expect(mecab.part_of_speech_detail1).to be_nil
      end
    end
  end

  describe "#to_s" do
    it "returns MeCab format string" do
      mecab = described_class.new
      mecab.parse("走っ\t動詞,自立,*,*,五段・ラ行,連用タ接続,走る,ハシッ,ハシッ")

      expected = "走っ\t動詞,自立,*,*,五段・ラ行,連用タ接続,走る,ハシッ,ハシッ"
      expect(mecab.to_s).to eq(expected)
    end
  end

  describe "#to_hash" do
    it "returns hash representation" do
      mecab = described_class.new
      mecab.parse("走っ\t動詞,自立,*,*,五段・ラ行,連用タ接続,走る,ハシッ,ハシッ")

      expected_hash = {
        surface: "走っ",
        part_of_speech: "動詞",
        part_of_speech_detail1: "自立",
        part_of_speech_detail2: nil,
        part_of_speech_detail3: nil,
        inflection_type: "五段・ラ行",
        inflection_form: "連用タ接続",
        base_form: "走る",
        reading: "ハシッ",
        pronunciation: "ハシッ"
      }

      expect(mecab.to_hash).to eq(expected_hash)
    end
  end

  describe "#put_yaml" do
    it "outputs YAML format to stdout" do
      mecab = described_class.new
      mecab.parse("走っ\t動詞,自立,*,*,五段・ラ行,連用タ接続,走る,ハシッ,ハシッ")

      expected_hash = {
        surface: "走っ",
        part_of_speech: "動詞",
        part_of_speech_detail1: "自立",
        part_of_speech_detail2: nil,
        part_of_speech_detail3: nil,
        inflection_type: "五段・ラ行",
        inflection_form: "連用タ接続",
        base_form: "走る",
        reading: "ハシッ",
        pronunciation: "ハシッ"
      }

      expect { mecab.put_yaml }.to output(expected_hash.to_yaml).to_stdout
    end

    it "outputs YAML for an instance with nil attributes" do
      mecab = described_class.new

      expected_hash = {
        surface: nil,
        part_of_speech: nil,
        part_of_speech_detail1: nil,
        part_of_speech_detail2: nil,
        part_of_speech_detail3: nil,
        inflection_type: nil,
        inflection_form: nil,
        base_form: nil,
        reading: nil,
        pronunciation: nil
      }

      expect { mecab.put_yaml }.to output(expected_hash.to_yaml).to_stdout
    end

    it "outputs YAML for partially parsed data" do
      mecab = described_class.new
      mecab.parse("走る\t動詞")

      expected_hash = {
        surface: "走る",
        part_of_speech: "動詞",
        part_of_speech_detail1: nil,
        part_of_speech_detail2: nil,
        part_of_speech_detail3: nil,
        inflection_type: nil,
        inflection_form: nil,
        base_form: nil,
        reading: nil,
        pronunciation: nil
      }

      expect { mecab.put_yaml }.to output(expected_hash.to_yaml).to_stdout
    end
  end

  describe "convert_asterisk private method" do
    it "converts asterisks to nil correctly" do
      mecab = described_class.new
      mecab.parse("test\t名詞,一般,*,*,*,*,test,テスト,テスト")

      expect(mecab.part_of_speech_detail2).to be_nil
      expect(mecab.part_of_speech_detail3).to be_nil
      expect(mecab.inflection_type).to be_nil
      expect(mecab.inflection_form).to be_nil
    end
  end
end
