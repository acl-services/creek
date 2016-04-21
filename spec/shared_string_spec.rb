require './spec/spec_helper'

describe Creek::SharedStrings do
  let(:xml_file) { File.open("spec/fixtures/sst.xml") }
  let(:file) { double(:file, :exist? => true, :open => xml_file) }
  let(:files) { double(:files, :file => file) }

  describe "#dictionary" do
    subject(:dictionary) { described_class.new(files).dictionary }

    it "parses rich text strings correctly" do
      expect(dictionary.size).to eq 5
      expect(dictionary).to match_array(['Cell A1', 'Cell B1', 'My Cell', 'Cell A2', 'Cell B2'])
    end
  end
end
