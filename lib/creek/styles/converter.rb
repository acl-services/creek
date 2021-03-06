require 'set'

module Creek
  class Styles
    class Converter
      include Creek::Styles::Constants
      include Creek::CellValueExtractor

      ##
      # The heart of typecasting. The ruby type is determined either explicitly
      # from the cell xml or implicitly from the cell style, and this
      # method expects that work to have been done already. This, then,
      # takes the type we determined it to be and casts the cell value
      # to that type.
      #
      # types:
      # - s: shared string (see #shared_string)
      # - n: number (cast to a float)
      # - b: boolean
      # - str: string
      # - inlineStr: string
      # - ruby symbol: for when type has been determined by style
      #
      # options:
      # - shared_strings: needed for 's' (shared string) type
      # - base_date: from what date to begin, see method #base_date

      DATE_TYPES = [:date, :time, :date_time].to_set
      def self.call(value, type, style, options = {})
        return nil if value.nil? || value.empty?

        # Sometimes the type is dictated by the style alone
        if type.nil? || (type == 'n' && DATE_TYPES.include?(style))
          type = style
        end

        case type

        ##
        # There are few built-in types
        ##

        when 's' # shared string
          shared_string_value(value, options)
        when 'n' # number
          value.to_f
        when 'b'
          value.to_i == 1
        when 'str'
          value
        when 'inlineStr'
          value

        ##
        # Type can also be determined by a style,
        # detected earlier and cast here by its standardized symbol
        ##

        when :string, :unsupported
          value
        when :fixnum
          value.to_i
        when :float
          value.to_f
        when :percentage
          value.to_f / 100
        when :date, :time, :date_time
          convert_date(value, options)
        when :bignum
          convert_bignum(value)

        ## Nothing matched
        else
          value
        end
      end

      # the trickiest. note that  all these formats can vary on
      # whether they actually contain a date, time, or datetime.
      def self.convert_date(value, options)
        value                        = value.to_f
        days_since_date_system_start = value.to_i
        fraction_of_24               = value - days_since_date_system_start

        # http://stackoverflow.com/questions/10559767/how-to-convert-ms-excel-date-from-float-to-date-format-in-ruby
        date = options.fetch(:base_date, Date.new(1899, 12, 30)) + days_since_date_system_start

        if fraction_of_24 > 0 # there is a time associated
          seconds = (fraction_of_24 * 86400).round
          time = create_time(date) + seconds

          time.year == 1899 ? time : create_date_time(time)
        else
          date
        end
      end

      def self.create_time(date)
        Time.utc(date.year, date.month, date.day)
      end

      def self.create_date_time(time)
        DateTime.civil(time.year, time.month, time.day, time.hour, time.min, time.sec)
      end

      def self.convert_bignum(value)
        if defined?(BigDecimal)
          BigDecimal.new(value)
        else
          value.to_f
        end
      end

      def self.shared_string_value(value, options)
        return options[:shared_strings][value.to_i] unless options[:with_html]
        node_options = {
          :ignore_phonetic_fields => options[:ignore_phonetic_fields]
        }

        if options[:html_cell]
          node_options[:cell_style] = options[:cell_style]

          html_from(options[:shared_strings][value.to_i], node_options)
        else
          text_from(options[:shared_strings][value.to_i], node_options)
        end
      end
    end
  end
end
