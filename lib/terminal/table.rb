# coding: utf-8

require "gemoji"

class String
  def twidth
    result = 0

    # 4 code point emoji
    %w{ ☺️ ❤️ }.each do |c|
      result += -3 * scan(c).size
    end

    # 3 code point emoji
    %w{ ♍️ }.each do |c|
      result += -2 * scan(c).size
    end

    chars.inject(result) do |result, c|
      if c.ord <= 126
        result += 1
      elsif %w{  ͡  ͜ }.include?(c)
        # zero width
        result += 0
      elsif %w{ ě ì • é · ♪ … ω ˊ ˋ √ “ ” ☻ ※ ◎ ◆ ‘ ★ ’ — ° ʖ ¯ ≥ ≤ }.include?(c)
        result += 1
      elsif c == ' ' # ord == 8198
        result += 1
      elsif Emoji.find_by_unicode(c)
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

    def initialize(object = nil)
      @rows = []
      @headings = []
      @column_widths = []

      if object && object.respond_to?(:to_hash)
        @headings = object.to_hash.keys.map(&:to_s)
        @rows = [object.to_hash.values]
      end

      yield self if block_given?
      recalculate_column_widths!
    end

    def rows=(rows)
      @rows = rows.map { |row| row.map { |item| item.to_s.gsub("\n", " ") } }
    end

    def headings=(headings)
      @headings = headings
    end

    def recalculate_column_widths!
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
  end
end
