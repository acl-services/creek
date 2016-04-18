module Creek
  class Creek::Extractor
    include Creek::HtmlExtractor

    attr_reader :node, :options

    def initialize(node, options = {})
      @node, @options = node, options
    end

    def extract
      if options[:with_html]
        { :text => text_from(node), :html => html_from(node) }
      else
        text_from(node)
      end
    end

    private

    def text_from(node)
      node.css("t").map(&:content).join('')
    end
  end
end
