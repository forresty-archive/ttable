# coding: utf-8

require "gemoji"

class String
  def twidth
    # ❤️ is not correctly handled...
    chars.inject(0) do |result, c|
      if c.ord <= 126
        result += 1
      elsif %w{ • é · ♪ }.include?(c)
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
    attr_accessor :column_widths

    def initialize
      @rows = []
      @column_widths = []
      yield self if block_given?
      recalculate_column_widths!
    end

    def recalculate_column_widths!
      (0...@rows.first.size).each do |col|
        @column_widths[col] = @rows.map { |row| row[col].to_s.twidth }.max
      end
    end

    def to_s
      header_and_footer = '+' + @column_widths.map { |w| '-' * (w + 2) }.join('+') + '+' + "\n"

      result = header_and_footer

      @rows.each do |row|
        result += '| ' + row.each_with_index.map { |grid, i| grid.to_s.tljust(@column_widths[i]) }.join(' | ') + " |\n"
      end

      result + header_and_footer
    end
  end
end
