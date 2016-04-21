require 'zip/filesystem'
require 'nokogiri'

module Creek
  class Creek::SharedStrings
    attr_reader :files, :options, :dictionary

    def initialize(files, options = {})
      @files, @options = files, options
      @dictionary = parse_shared_strings
    end

    def parse_shared_strings
      path = "xl/sharedStrings.xml"

      if files.file.exist?(path)
        doc = files.file.open path
        xml = Nokogiri::XML::Document.parse doc

        @dictionary ||= xml.css('si').map { |si| Creek::Extractor.new(si, options).extract }
      end
    end
  end
end
