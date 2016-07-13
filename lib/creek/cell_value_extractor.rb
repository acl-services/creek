module Creek
  module CellValueExtractor
    EXCEL_STYLE_MAP = { :b => :strong, :i => :em, :u => :u }

    def self.included(base)
      base.extend ClassMethods
    end

    private

    def text_from(node, options = {})
      self.class.text_from(node, options)
    end

    module ClassMethods
      def text_from(node, options = {})
        text_nodes = node.css("t").reject do |text_node|
          options[:ignore_phonetic_fields] && text_node.parent.name == "rPh"
        end

        text_nodes.map(&:content).join('')
      end

      def html_from(node, html_options = {})
        node.children.map { |elem| html_from_xml(elem, html_options) }.join.gsub(/[\r\n]/, "<br>")
      end

      def html_from_xml(node, html_options)
        return "" if html_options[:ignore_phonetic_fields] && node.name == "rPh"

        str = ""
        xml_elems = { strong: false, em: false, u: false }

        node.children.each do |elem|
          case elem.name
          when "rPr"
            EXCEL_STYLE_MAP.each do |property, tag|
              xml_elems[tag] = true unless elem.children.css(property.to_s).empty?
            end
          when "t", "text"
            if node.css("rPr sz, rPr rFont").empty?
              xml_elems.merge!(html_options[:cell_style]) { |_, xml, cell| xml | cell }
            end

            str << create_html(elem.content, xml_elems)
          end
        end

        str
      end

      # This will return an html string
      def create_html(text, formatting)
        formatting.inject(text) { |res, (tag, val)| val ? "<#{tag}>#{res}</#{tag}>" : res }
      end
    end
  end
end
