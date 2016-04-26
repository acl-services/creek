require './spec/spec_helper'

describe Creek::Styles::StyleTypes do
  describe "#call" do
    let(:xml_file) { File.open('spec/fixtures/styles/first.xml') }
    let(:doc) { Nokogiri::XML(xml_file) }
    subject(:style_types) { described_class.new(doc).call }

    it "returns array of styletypes with mapping to ruby types" do
      expect(style_types.size).to eq 8
      expect(style_types).to eq [
        :unsupported, :unsupported, :unsupported, :date_time,
        :unsupported, :unsupported, :unsupported, :unsupported
      ]
    end
  end
end
