require 'zip/filesystem'
require 'nokogiri'
require 'date'

module Creek
  class Creek::Book
    attr_reader :files, :sheets, :shared_strings, :cell_styles, :options

    DATE_1900 = Date.new(1899, 12, 30).freeze
    DATE_1904 = Date.new(1904, 1, 1).freeze

    def initialize(path, options = {})
      if options.fetch(:check_file_extension, true)
        extension = File.extname(options[:original_filename] || path).downcase
        raise 'Not a valid file format.' unless (['.xlsx', '.xlsm'].include? extension)
      end

      @files = Zip::File.open(path)
      @cell_styles = CellStyles.new(styles)
      @shared_strings = SharedStrings.new(files, options)
      @options = options
    end

    def sheets
      doc = @files.file.open "xl/workbook.xml"
      xml = Nokogiri::XML::Document.parse doc
      rels_doc = @files.file.open "xl/_rels/workbook.xml.rels"
      rels = Nokogiri::XML::Document.parse(rels_doc).css("Relationship")
      @sheets = xml.css('sheet').map do |sheet|
        sheetfile = rels.find { |el| sheet.attr("r:id") == el.attr("Id") }.attr("Target")
        Sheet.new(
          self,
          sheet.attr("name"),
          sheet.attr("sheetid"),
          sheet.attr("state"),
          sheet.attr("visible"),
          sheet.attr("r:id"),
          sheetfile
        )
      end
    end

    def style_types
      @style_types ||= styles.style_types
    end

    def close
      @files.close
    end

    def base_date
      @base_date ||=
      begin
        # Default to 1900 (minus one day due to excel quirk) but use 1904 if
        # it's set in the Workbook's workbookPr
        # http://msdn.microsoft.com/en-us/library/ff530155(v=office.12).aspx
        result = DATE_1900 # default

        doc = @files.file.open "xl/workbook.xml"
        xml = Nokogiri::XML::Document.parse doc
        xml.css('workbookPr[date1904]').each do |workbookPr|
          if workbookPr['date1904'] =~ /true|1/i
            result = DATE_1904
            break
          end
        end

        result
      end
    end

    private

    def styles
      @_styles ||= Creek::Styles.new(files)
    end
  end
end
