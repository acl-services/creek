module Creek
  class Creek::CellStyles
    FONT_STYLES = { :strong => :b, :em => :i, :u => :u }

    attr_reader :styles

    def initialize(styles)
      @styles = styles
    end

    def definitions
      return [] unless styles_xml

      styles_xml.css('styleSheet cellXfs xf').map do |xf|
        fonts[xf['fontId'].to_i]
      end
    end

    def [](index)
      definitions[index]
    end

    def styles_xml
      styles.styles_xml
    end

    private

    def fonts
      @_fonts ||= begin
        styles_xml.css('styleSheet fonts font').map do |font_el|
          {}.tap do |font|
            FONT_STYLES.each do |key, font_tag|
              font[key] = !font_el.css("#{font_tag}").empty?
            end
          end
        end
      end
    end
  end
end
