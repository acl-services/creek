module Creek
  module HtmlExtractor
    EXCEL_STYLE_MAP = { :b => :strong, :i => :em, :u => :u }

    def self.included(base)
      base.extend ClassMethods
    end

    private

    def html_from_cell(value, cell_style)
      self.class.html_from_cell(value, cell_style)
    end

    def create_html(text, formatting)
      self.class.create_html(text, formatting)
    end

    def html_from(node)
      html_string = ""

      node.children.each do |elem|
        html_string <<
          case elem.name
            when "r" then html_from_xml(elem)
            when "t" then elem.content
            else ""
          end
      end

      html_string.gsub(/[\r\n]/, "<br>")
    end

    def html_from_xml(node)
      str = ""
      xml_elems = { strong: false, em: false, u: false }

      node.children.each do |elem|
        case elem.name
        when "rPr"
          elem.children.each do |property|
            property_name = property.name.to_sym
            xml_elems[EXCEL_STYLE_MAP[property_name]] = true if EXCEL_STYLE_MAP.keys.include?(property_name)
          end
        when "t"
          str << create_html(elem.content, xml_elems)
        end
      end

      str
    end

    module ClassMethods
      def html_from_cell(value, cell_style)
        create_html(value, cell_style)
      end

      # This will return an html string
      def create_html(text, formatting)
        html = ""

        formatting.each do |elem, val|
          html << "<#{elem}>" if val
        end
        html << text

        # reverse formatting
        Hash[formatting.to_a.reverse].each do |elem, val|
          html << "</#{elem}>" if val
        end

        html
      end
    end
  end
end
