module Creek
  class Styles
    attr_accessor :files

    def initialize(files)
      @files = files
    end

    def path
      "xl/styles.xml"
    end

    def styles_xml
      @styles_xml ||= begin
        if files.file.exist?(path)
          doc = files.file.open path
          Nokogiri::XML::Document.parse doc
        end
      end
    end

    def style_types
      @style_types ||= begin
        Creek::Styles::StyleTypes.new(styles_xml).call
      end
    end
  end
end
