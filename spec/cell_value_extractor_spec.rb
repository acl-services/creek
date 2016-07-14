require "spec_helper"

describe Creek::CellValueExtractor do
  let(:xml_file) { File.open("spec/fixtures/sst.xml") }
  let(:nodes) { Nokogiri::XML::Document.parse(xml_file).css("si") }

  class DummyClass
    include Creek::CellValueExtractor
  end

  describe ".text_from" do
    let(:node) { nodes[0] }
    let(:options) { {} }

    subject(:text) { DummyClass.text_from(node, options) }

    it { is_expected.to eq "Cell A1" }

    context "when node contains subnodes and styles" do
      let(:node) { nodes[3] }

      it "ignores any styles and join text from all subnodes" do
        expect(text).to eq "Cell A2"
      end
    end

    context "when node contains phonetic fields" do
      let(:node) { nodes[7] }

      it "includes all phonetic fields" do
        expect(text).to eq "契約条件登録を誤るケイヤク"
      end

      context "and :ignore_phonetic_fields option is present" do
        let(:options) { { :ignore_phonetic_fields => true } }

        it "ignores all phonetic fields" do
          expect(text).to eq "契約条件登録を誤る"
        end
      end
    end
  end

  describe ".html_from_xml" do
    let(:node) { nodes[0] }
    let(:options) { {} }

    subject(:html_from_xml) { DummyClass.html_from(node, options) }

    it { is_expected.to eq "Cell A1" }

    context "when node has 'bold' styles" do
      let(:node) { nodes[3] }

      it { is_expected.to eq "Cell <strong>A2</strong>" }
    end

    context "when node has 'italic' styles" do
      let(:node) { nodes[4] }

      it { is_expected.to eq "Cell <em>B2</em>" }
    end

    context "when node has 'underline' styles" do
      let(:node) { nodes[5] }

      it { is_expected.to eq "Cell <u>B3</u>" }
    end

    context "when cell has styles" do
      let(:options) { { :cell_style => { strong: true, em: true, u: true } } }

      it { is_expected.to eq "<u><em><strong>Cell A1</strong></em></u>" }

      context "and subnode has own styles" do
        let(:node) { nodes[5] }

        it { is_expected.to eq "<u><em><strong>Cell </strong></em></u><u>B3</u>" }
      end
    end

    context "when node has phonetic fields" do
      let(:node) { nodes[7] }

      it { is_expected.to eq "契約条件登録を誤るケイヤク" }

      context "and :ignore_phonetic_fields option is present" do
        let(:options) { { :ignore_phonetic_fields => true } }

        it { is_expected.to eq "契約条件登録を誤る" }
      end
    end
  end

  describe ".html_from" do
    let(:node) { nodes[0] }
    let(:options) { {} }

    subject(:parse_html_values) { DummyClass.html_from(node, options) }

    it "parses html from child node" do
      expect(DummyClass).to receive(:html_from_xml)
        .with(an_instance_of(Nokogiri::XML::Element), any_args).once

      parse_html_values
    end

    context "when node has subnodes" do
      let(:node) { nodes[3] }

      it "parses html from ALL child nodes" do
        expect(DummyClass).to receive(:html_from_xml)
          .with(an_instance_of(Nokogiri::XML::Element), any_args)
          .exactly(3).times

        parse_html_values
      end
    end

    context "when node has text with line breaks" do
      let(:node) { nodes[6] }

      before do
        allow(DummyClass).to receive(:html_from_xml).and_return("\nLine with break\n")
      end

      it { is_expected.to eq "<br>Line with break<br>" }
    end
  end
end
