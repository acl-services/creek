require 'zip/filesystem'
require 'nokogiri'

module Creek
  class Creek::Sheet
    attr_reader :book, :name, :sheetid, :state, :visible, :rid, :index

    def initialize book, name, sheetid, state, visible, rid, sheetfile
      @book = book
      @name = name
      @sheetid = sheetid
      @visible = visible
      @rid = rid
      @state = state
      @sheetfile = sheetfile
    end

    ##
    # Provides an Enumerator that returns a hash representing each row.
    # The key of the hash is the Cell id and the value is the value of the cell.
    def rows
      rows_generator
    end

    ##
    # Provides an Enumerator that returns a hash representing each row.
    # The hash contains meta data of the row and a 'cells' embended hash which contains the cell contents.
    def rows_with_meta_data
      rows_generator true
    end

    private

    ##
    # Returns a hash per row that includes the cell ids and values.
    # Empty cells will be also included in the hash with a nil value.
    def rows_generator include_meta_data=false
      path = "xl/#{@sheetfile}"
      if @book.files.file.exist?(path)
        # SAX parsing, Each element in the stream comes through as two events:
        # one to open the element and one to close it.
        opener = Nokogiri::XML::Reader::TYPE_ELEMENT
        closer = Nokogiri::XML::Reader::TYPE_END_ELEMENT

        Enumerator.new do |y|
          row, cells, cell = nil, {}, nil
          cell_type  = nil
          cell_style_idx = nil

          @book.files.file.open(path) do |xml|
            Nokogiri::XML::Reader.from_io(xml).each do |node|
              if (node.name.eql? 'row') and (node.node_type.eql? opener)
                row = node.attributes
                row['cells'] = Hash.new
                cells = Hash.new
                y << (include_meta_data ? row : cells) if node.self_closing?
              elsif (node.name.eql? 'row') and (node.node_type.eql? closer)
                processed_cells = fill_in_empty_cells(cells, row['r'], cell)
                row['cells'] = processed_cells
                y << (include_meta_data ? row : processed_cells)
              elsif (node.name.eql? 'c') and (node.node_type.eql? opener)
                cell_type      = node.attributes['t']
                cell_style_idx = node.attributes['s']
                cell           = node.attributes['r']
              elsif (node.name.eql? 'v') and (node.node_type.eql? opener)
                unless cell.nil?
                  cells[cell] = convert(node.inner_xml, cell_type, cell_style_idx, cell)
                end
              end
            end
          end
        end
      end
    end

    def convert(value, type, style_idx, cell_name)
      style = book.style_types[style_idx.to_i]

      Creek::Styles::Converter.call(value, type, style, converter_options(cell_name, style_idx))
    end

    def converter_options(cell_name, style_idx)
      if book.options[:with_html]
        default_converter_options.merge(
          :with_html => true,
          :html_cell => html_cell?(cell_name),
          :cell_style => book.cell_styles[style_idx.to_i]
        )
      else
        default_converter_options
      end
    end

    def default_converter_options
      @_default_converter_options ||= {
        :shared_strings => book.shared_strings.dictionary,
        :base_date => book.base_date,
        :ignore_phonetic_fields => book.options[:ignore_phonetic_fields]
      }
    end

    def html_cell?(cell_name)
      cell_column_name = cell_name[/[A-Z]+/]
      html_columns && html_columns.include?(cell_column_name)
    end

    ##
    # The unzipped XML file does not contain any node for empty cells.
    # Empty cells are being padded in using this function
    def fill_in_empty_cells(cells, row_number, last_col)
      new_cells = Hash.new

      unless cells.empty?
        last_col = last_col.gsub(row_number, '')

        ("A"..last_col).each do |column|
          id = "#{column}#{row_number}"
          new_cells[id] = cells[id]
        end
      end

      new_cells
    end

    def html_columns
      book.options[:html_columns]
    end
  end
end
