# coding: utf-8

require "gemoji"

class String
  CHARS_OF_WIDTH_OF_1 = %w{ ě ì • é · ♪ … ω ˊ ˋ √ “ ” ☻ ※ ◎ ◆ ‘ ★ ’ — ° ʖ ¯ ≥ ≤
    ≧ ∇ ≦  ❤ ☺ ╭ ╯ ε ╰ ╮ з ∠ → ☞ ë ϵ Θ ϶ Ο Ι ⏎ }
  CHARS_OF_WIDTH_OF_0 = %w{  ͡  ͜  ̫ }

  def twidth
    result = 0

    %w{ ☺️ ❤️ ♍️ ☔️ }.each do |c|
      if include?(c)
        result += 1 * scan(c).size
        gsub!(c, '')
      end
    end

    chars.inject(result) do |result, c|
      if c.ord <= 126
        result += 1
      elsif CHARS_OF_WIDTH_OF_0.include?(c)
        # zero width
        result += 0
      elsif CHARS_OF_WIDTH_OF_1.include?(c)
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
        hash.keep_if { |k, v| options[:only].map(&:to_sym).include?(k) }
      elsif options[:except]
        hash.delete_if { |k, v| options[:except].map(&:to_sym).include?(k) }
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
