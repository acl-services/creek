require 'zip/filesystem'
require 'nokogiri'

module Creek
  class Creek::SharedStrings
    include Creek::CellValueExtractor

    attr_reader :files, :options, :dictionary

    def initialize(files, options = {})
      @files = files
      @options = options
      @dictionary = parse_shared_strings
    end

    def parse_shared_strings
      path = "xl/sharedStrings.xml"

      if files.file.exist?(path)
        doc = files.file.open path
        xml = Nokogiri::XML::Document.parse doc

        @dictionary ||= xml.css('si').map do |node|
          options[:with_html] ? node : text_from(node)
        end
      end
    end
  end
end
