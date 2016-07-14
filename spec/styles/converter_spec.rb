require './spec/spec_helper'

describe Creek::Styles::Converter do
  describe ".call" do
    let(:type) { "str" }
    let(:style) { :some_style }
    subject(:converted_value) { described_class.call(value, type, style) }

    context "when value is nil" do
      let(:value) { nil }

      it { is_expected.to be_nil }
    end

    context "when value is empty" do
      let(:value) { "" }

      it { is_expected.to be_nil }
    end

    context "when type is string" do
      let(:value) { "string" }
      let(:type) { "str" }

      it { is_expected.to eq "string" }
    end

    context "when type is number" do
      let(:value) { "4" }
      let(:type) { "n" }

      it { is_expected.to eq 4.0 }
    end

    context "when type is boolean" do
      let(:value) { "1" }
      let(:type) { "b" }

      it { is_expected.to be_truthy }
    end

    context "when type is date" do
      let(:value) { "41275" }
      let(:type) { "n" }
      let(:style) { :date_time }

      it { is_expected.to eq Date.new(2013, 01, 01) }

      context "when type is time" do
        let(:value) { "0.3833333333333333" }

        it { is_expected.to eq Time.utc(1899, 12, 30, 9, 12) }
      end

      context "when type is date time" do
        let(:value) { "40910.5" }

        it { is_expected.to eq DateTime.civil(2012, 1, 2, 12, 0) }
      end
    end
  end

  describe ".shared_string_value" do
    let(:shared_strings) { double(:shared_strings, :[] => shared_string_value) }
    let(:shared_string_value) { "value" }

    let(:value) { 0 }
    let(:options) { { :shared_strings => shared_strings }.merge(additional_options) }
    let(:additional_options) { {} }

    subject(:value_from_node) do
      described_class.shared_string_value(value, options)
    end

    it { is_expected.to eq "value" }

    context "when :with_html option is present" do
      let(:additional_options) { { :with_html => true } }

      it "returns text from node" do
        expect(described_class).to receive(:text_from).with("value", hash_including(:ignore_phonetic_fields))

        value_from_node
      end

      context "when :ignore_phonetic_fields option is present" do
        let(:additional_options) { { :with_html => true, :ignore_phonetic_fields => true } }

        it "returns text from node" do
          expect(described_class).to receive(:text_from).with("value", hash_including(:ignore_phonetic_fields => true))

          value_from_node
        end
      end

      context "when :html_cell option is present" do
        let(:additional_options) { { :with_html => true, :html_cell => true } }

        it "returns html from node" do
          expect(described_class).to receive(:html_from).with("value", hash_including(:cell_style))

          value_from_node
        end

        context "when :ignore_phonetic_fields option is present" do
          let(:additional_options) { { :with_html => true, :html_cell => true, :ignore_phonetic_fields => true } }

          it "returns text from node" do
            expect(described_class).to receive(:html_from)
              .with("value", hash_including(:ignore_phonetic_fields => true))

            value_from_node
          end
        end
      end
    end
  end
end
