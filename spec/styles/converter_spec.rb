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
end
