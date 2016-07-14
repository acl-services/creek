require './spec/spec_helper'

describe Creek::SharedStrings do
  let(:xml_file) { File.open("spec/fixtures/sst.xml") }
  let(:file) { double(:file, :exist? => true, :open => xml_file) }
  let(:files) { double(:files, :file => file) }

  describe "#dictionary" do
    let(:options) { {} }

    subject(:dictionary) { described_class.new(files, options).dictionary }
    let(:parse_shared_strings) { dictionary }

    it "returns text from nodes" do
      expect(described_class).to receive(:text_from)
        .with(an_instance_of(Nokogiri::XML::Element), any_args)
        .exactly(8).times

      parse_shared_strings
    end

    context "when :ignore_phonetic_fields option is present" do
      let(:options) { { :ignore_phonetic_fields => true } }

      it "ignores phonetic fields" do
        expect(described_class).to receive(:text_from)
          .with(an_instance_of(Nokogiri::XML::Element), hash_including(:ignore_phonetic_fields => true))
          .exactly(8).times

        parse_shared_strings
      end
    end

    context "when :with_html option is present" do
      let(:options) { { :with_html => true } }

      it "returns xml nodes" do
        expect(dictionary.size).to eq 8
        expect(dictionary).to all be_instance_of Nokogiri::XML::Element
      end
    end
  end
end
