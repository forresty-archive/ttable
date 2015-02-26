# coding: utf-8

require "gemoji"

class String
  CHAR_CODES_OF_WIDTH_1 = [706, 707, 713, 714, 715, 717, 726, 728, 730, 757, 758, 920,
                           921, 927, 931, 949, 969, 1013, 1014, 1044, 1053, 1072, 1076,
                           1079, 1090, 1096, 1342, 1608, 1641, 1782, 2919, 2920, 3232,
                           3237, 3248, 3267, 3589, 3665, 3844, 3900, 3901, 5026, 5046, 5072, 5603,
                           5608, 7447, 7461, 7500, 7506, 8198, 8203, 8212, 8214, 8216, 8217,
                           8220, 8221, 8226, 8230, 8242, 8248, 8251, 8254, 8316, 8317,
                           8318, 8320, 8330, 8333, 8334, 8451, 8461, 8469, 8545, 8592,
                           8594, 8595, 8704, 8711, 8730, 8736, 8743, 8745, 8746, 8750,
                           8804, 8805, 8806, 8807, 8857, 9000, 9166, 9472, 9473, 9484,
                           9488, 9517, 9518, 9531, 9573, 9581, 9582, 9583, 9584, 9587,
                           9600, 9604, 9608, 9612, 9633, 9649, 9651, 9660, 9661, 9670,
                           9675, 9678, 9679, 9697, 9728, 9729, 9730, 9733, 9734, 9752,
                           9756, 9758, 9786, 9787, 9794, 9818, 9825, 9829, 9834, 9836,
                           9996, 9999, 10004, 10008, 10023, 10023, 10026, 10047, 10048,
                           10084, 10085, 10086, 10102, 11015, 57643, 58141, 58370, 58381,
                           58387]

  MULTI_CHAR_OF_WIDTH_1 = %w{ ☺️ ❤️ ♍️ ☔️ ‾᷄ ‾᷅ ⁻̫ ✖️ 😂 ☀︎ ❓ ⁉️ ☁︎ ⬇️ ❄️ ✌️ ♨️ 6⃣ ♻️ ♒️
                              ✏️ 🇨🇳 ☁️ ✈️ ☀️ ♥️ ⚡️ ✔️ 🇰🇷 ⌛️ }
  MULTI_CHAR_OF_WIDTH_2 = %w{ ・᷄ ・᷅ ㊙️ }

  def twidth
    result = 0

    MULTI_CHAR_OF_WIDTH_1.each do |c|
      if include?(c)
        result += 1 * scan(c).size
        gsub!(c, '')
      end
    end

    MULTI_CHAR_OF_WIDTH_2.each do |c|
      if include?(c)
        result += 2 * scan(c).size
        gsub!(c, '')
      end
    end

    chars.inject(result) do |result, c|
      case c.ord
      when (0..0x7F) # Basic Latin
        result += 1
      when (0x80..0xFF) # Latin-1 Supplement
        result += 1
      when (0x100..0x17F) # Latin Extended-A
        result += 1
      when (0x180..0x24F) # Latin Extended-B
        result += 1
      when (0x2C60..0x2C7F) # Latin Extended-C
        result += 1
      when (0xA720..0xA7FF) # Latin Extended-D
        result += 1
      when (0xAB30..0xAB6F) # Latin Extended-E
        result += 1
      when (0x1E00..0x1EFF) # Latin Extended Additional
        result += 1
      when (0xFB00..0xFB06) # Latin Ligatures
        result += 1

      when (0x250..0x2AF) # IPA Extensions
        result += 1
      when (0x300..0x36F) # Combining Diacritical Marks
        result += 0
      when (0x1DC0..0x1DFF) # Combining Diacritical Marks Supplement
        result += 0

      # http://www.unicode.org/charts/PDF/U20D0.pdf
      # Combining Diacritical Marks for Symbols
      # Range: 20D0–20FF
      when (0x20D0..0x20DC)
        result += 0

      # http://www.unicode.org/charts/PDF/U0600.pdf
      # Arabic
      # Range: 0600–06FF
      when (0x610..0x614) # Honorifics
        result += 0
      when 0x615 # Koranic annotation sign
        result += 0
      when 0x616 # Extended Arabic mark
        result += 0
      when (0x617..0x61A) # Koranic annotation signs
        result += 0
      when (0x6D6..0x6DC) # Koranic annotation signs
        result += 0

      # http://www.unicode.org/charts/PDF/U0900.pdf
      # Devanagari
      # Range: 0900–097F
      when (0x941..0x948) # Dependent vowel signs
        result += 0

      # http://www.unicode.org/charts/PDF/U0A80.pdf
      # Gujarati
      # Range: 0A80–0AFF
      when (0xAC1..0xAC8) # Dependent vowel signs
        result += 0

      # http://www.unicode.org/charts/PDF/U0E00.pdf
      # Thai
      # Range: 0E00–0E7F
      when (0xE34..0xE3A) # Vowels
        result += 0
      when (0xE48..0xE4B) # Tone marks
        result += 0

      # http://www.unicode.org/charts/PDF/UFF00.pdf
      # Halfwidth and Fullwidth Forms
      # Range: FF00–FFEF
      when (0xFF01..0xFF5E) # Fullwidth ASCII variants
        result += 2
      when (0xFF5F..0xFF60) # Fullwidth brackets
        result += 2
      when (0xFF61..0xFF64) # Halfwidth CJK punctuation
        result += 1
      when (0xFF65..0xFF9F) # Halfwidth Katakana variants
        result += 1
      when (0xFFA0..0xFFDC) # Halfwidth Hangul variants
        result += 1
      when (0xFFE0..0xFFE6) # Fullwidth symbol variants
        result += 2
      when (0xFFE8..0xFFEE) # Halfwidth symbol variants
        result += 1

      when *CHAR_CODES_OF_WIDTH_1
        result += 1
      when lambda { |ord| Emoji.find_by_unicode([ord].pack('U*')) }
        result += 1
      else
        result += 2
      end
    end
  end

  def tljust(width)
    if width > twidth
      self + ' ' * (width - twidth)
    else
      self
    end
  end
end

module Terminal
  class Table
    attr_accessor :rows
    attr_accessor :headings
    attr_accessor :column_widths
    attr_accessor :new_line_symbol

    def initialize(object = nil, options = {})
      @rows = []
      @headings = []
      @column_widths = []

      if options[:use_new_line_symbol]
        @new_line_symbol = '⏎'
      else
        @new_line_symbol = ' '
      end

      if options[:flatten]
        raise 'should be an array' unless object.respond_to?(:each)
        all_keys = object.each.map(&:keys).flatten.map(&:to_sym).uniq
        object.each do |hash|
          all_keys.each do |key|
            hash[key] = '' if hash[key].nil?
          end
        end
      end

      if object
        if object.is_a?(Hash)
          add_hash(object, options)
        elsif object.respond_to?(:each)
          object.each { |o| add_object(o, options) }
        else
          add_object(object, options)
        end
      end

      yield self if block_given?
      recalculate_column_widths!
    end

    def add_object(object, options)
      if object.respond_to?(:to_hash)
        add_hash(object.to_hash, options)
      elsif object.respond_to?(:each)
        @rows << object
      end
    end

    def add_hash(hash, options)
      if options[:only]
        hash.keep_if { |k, v| options[:only].map(&:to_sym).include?(k.to_sym) }
      elsif options[:except]
        hash.delete_if { |k, v| options[:except].map(&:to_sym).include?(k.to_sym) }
      end

      @headings = hash.keys.map(&:to_s)
      @rows << hash.values
    end

    def headings=(headings)
      @headings = headings
    end

    def recalculate_column_widths!
      @rows = rows.map { |row| row.map { |item| item.to_s.gsub("\r\n", @new_line_symbol).gsub("\n", @new_line_symbol).gsub("\r", @new_line_symbol) } }

      if @rows.count > 0
        (0...@rows.first.size).each do |col|
          @column_widths[col] = @rows.map { |row| row[col].to_s.twidth }.max
        end
      end

      if @headings.count > 0
        (0...@headings.size).each do |col|
          @column_widths[col] = [@column_widths[col] || 0, @headings[col].twidth].max
        end
      end
    end

    def to_s
      recalculate_column_widths!

      result = ''

      header_and_footer = '+' + @column_widths.map { |w| '-' * (w + 2) }.join('+') + '+' + "\n"

      if @headings.count > 0
        result += header_and_footer

        content = @headings.each_with_index.map { |grid, i| grid.to_s.tljust(@column_widths[i]) }

        result += '| ' + content.join(' | ') + " |\n"
      end

      result += header_and_footer

      @rows.each do |row|
        content = row.each_with_index.map { |grid, i| grid.to_s.tljust(@column_widths[i]) }

        result += '| ' + content.join(' | ') + " |\n"
      end

      result + header_and_footer
    end

    class << self
      def special_tokens
        String::CHARS_OF_WIDTH_OF_1 + String::CHARS_OF_WIDTH_OF_0
      end
    end
  end
end
