module Creek
  module CellValueExtractor
    EXCEL_STYLE_MAP = { :b => :strong, :i => :em, :u => :u }

    def self.included(base)
      base.extend ClassMethods
    end

    private

    def text_from(node)
      self.class.text_from(node)
    end

    module ClassMethods
      def text_from(node)
        node.css("t").map(&:content).join('')
      end

      def html_from(node, cell_style)
        html_string = ""

        node.children.each do |elem|
          html_string <<
            case elem.name
              when "r" then html_from_xml(elem, cell_style)
              when "t" then elem.content
              else ""
            end
        end

        html_string.gsub(/[\r\n]/, "<br>")
      end

      def html_from_xml(node, cell_style)
        str = ""
        xml_elems = { strong: false, em: false, u: false }

        node.children.each do |elem|
          case elem.name
          when "rPr"
            EXCEL_STYLE_MAP.each do |property, tag|
              xml_elems[tag] = true unless elem.children.css(property.to_s).empty?
            end
          when "t"
            xml_elems.merge!(cell_style) { |_, xml, cell| xml | cell } if node.css("rPr sz, rPr rFont").empty?
            str << create_html(elem.content, xml_elems)
          end
        end

        str
      end

      # This will return an html string
      def create_html(text, formatting)
        html = text

        formatting.each do |elem, val|
          html = "<#{elem}>#{html}</#{elem}>" if val
        end

        html
      end
    end
  end
end
