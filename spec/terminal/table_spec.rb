# coding: utf-8

require "spec_helper"

class Dummy
  attr_accessor :foo

  def to_hash
    { foo: @foo }
  end
end

class Dummy2
  attr_accessor :foo1, :foo2, :foo3

  def to_hash
    { foo1: @foo1, foo2: @foo2, foo3: @foo3 }
  end
end

module Terminal
  describe Table do
    describe 'class methods' do
      subject { Table }
      it { is_expected.to respond_to :special_tokens }
    end

    it { is_expected.to respond_to :to_s }

    describe 'initialize with array of array' do
      let(:array) { [%w{ hello 1 }, %w{ world 2 } ] }
      subject { Table.new(array) }

      expected = <<END
      +-------+---+
      | hello | 1 |
      | world | 2 |
      +-------+---+
END
      describe '#to_s' do
        subject { super().to_s }
        it { is_expected.to eq(expected.gsub(/^(\s+)/, '')) }
      end
    end

    describe 'initialize with hash' do
      let(:hash) { { foo: 'bar' } }

      subject { Table.new(hash) }

      expected = <<END
      +-----+
      | foo |
      +-----+
      | bar |
      +-----+
END
      describe '#to_s' do
        subject { super().to_s }
        it { is_expected.to eq(expected.gsub(/^(\s+)/, '')) }
      end
    end

    describe 'initialize with array of hashes' do
      let(:hash1) { { foo: 'bar1' } }
      let(:hash2) { { foo: 'bar2' } }

      subject { Table.new([hash1, hash2]) }

      expected = <<END
      +------+
      | foo  |
      +------+
      | bar1 |
      | bar2 |
      +------+
END
      describe '#to_s' do
        subject { super().to_s }
        it { is_expected.to eq(expected.gsub(/^(\s+)/, '')) }
      end
    end

    describe 'initialize with array of hashes' do
      let(:hash1) { { 'foo' => 'foo1', 'bar' => 'bar1' } }
      let(:hash2) { { 'foo' => 'foo2', 'bar' => 'bar2' } }

      subject { Table.new([hash1, hash2], only: %w{ foo }) }

      expected = <<END
      +------+
      | foo  |
      +------+
      | foo1 |
      | foo2 |
      +------+
END
      describe '#to_s' do
        subject { super().to_s }
        it { is_expected.to eq(expected.gsub(/^(\s+)/, '')) }
      end
    end

    describe 'initialize with object#to_hash' do
      let(:object) { Dummy.new.tap { |d| d.foo = 'bar' } }
      subject { Table.new(object) }

      expected = <<END
      +-----+
      | foo |
      +-----+
      | bar |
      +-----+
END
      describe '#to_s' do
        subject { super().to_s }
        it { is_expected.to eq(expected.gsub(/^(\s+)/, '')) }
      end
    end

    describe 'initialize with objects' do
      let(:object1) { Dummy.new.tap { |d| d.foo = 'bar1' } }
      let(:object2) { Dummy.new.tap { |d| d.foo = 'bar2' } }

      subject { Table.new([object1, object2]) }

      expected = <<END
      +------+
      | foo  |
      +------+
      | bar1 |
      | bar2 |
      +------+
END
      describe '#to_s' do
        subject { super().to_s }
        it { is_expected.to eq(expected.gsub(/^(\s+)/, '')) }
      end
    end

    describe 'initialize with object#to_hash and :only option' do
      let(:object) { Dummy2.new.tap { |d| d.foo1 = 'bar1'; d.foo2 = 'bar2'; d.foo3 = 'bar3' } }
      subject { Table.new(object, only: [:foo1, :foo2]) }

      expected = <<END
      +------+------+
      | foo1 | foo2 |
      +------+------+
      | bar1 | bar2 |
      +------+------+
END
      describe '#to_s' do
        subject { super().to_s }
        it { is_expected.to eq(expected.gsub(/^(\s+)/, '')) }
      end
    end

    describe 'initialize with object#to_hash and :only option' do
      let(:object) { Dummy2.new.tap { |d| d.foo1 = 'bar1'; d.foo2 = 'bar2'; d.foo3 = 'bar3' } }
      subject { Table.new(object, only: %w{ foo1 foo2 }) }

      expected = <<END
      +------+------+
      | foo1 | foo2 |
      +------+------+
      | bar1 | bar2 |
      +------+------+
END
      describe '#to_s' do
        subject { super().to_s }
        it { is_expected.to eq(expected.gsub(/^(\s+)/, '')) }
      end
    end

    describe 'initialize with object#to_hash and :except option' do
      let(:object) { Dummy2.new.tap { |d| d.foo1 = 'bar1'; d.foo2 = 'bar2'; d.foo3 = 'bar3' } }
      subject { Table.new(object, except: [:foo1, :foo3]) }

      expected = <<END
      +------+
      | foo2 |
      +------+
      | bar2 |
      +------+
END
      describe '#to_s' do
        subject { super().to_s }
        it { is_expected.to eq(expected.gsub(/^(\s+)/, '')) }
      end
    end

    describe 'initialize with array of irregular hashes' do
      let(:data) {
        [
          { :param=>"channel_id", :required=>true, :type=>"Integer" },
          { :param=>"limit", :required=>false, :type=>"Integer", :default=>30 },
          { :param=>"offset", :required=>false, :type=>"Integer", :default=>4611686018427387903 }
        ]
      }

      subject { Table.new(data, flatten: true) }
      expected = <<END
      +------------+----------+---------+---------------------+
      | param      | required | type    | default             |
      +------------+----------+---------+---------------------+
      | channel_id | true     | Integer |                     |
      | limit      | false    | Integer | 30                  |
      | offset     | false    | Integer | 4611686018427387903 |
      +------------+----------+---------+---------------------+
END
      describe '#to_s' do
        subject { super().to_s }
        it { is_expected.to eq(expected.gsub(/^(\s+)/, '')) }
      end
    end

    describe '#to_s' do
      context 'when empty' do
        subject { Table.new }

        describe '#to_s' do
          subject { super().to_s }
          it { is_expected.to eq("++\n++\n") }
        end
      end

      context 'new lines \n' do
        subject { Table.new { |t| t.rows = [["a\nb"]] } }

        expected = <<END
        +-----+
        | a b |
        +-----+
END
        describe '#to_s' do
          subject { super().to_s }
          it { is_expected.to eq(expected.gsub(/^(\s+)/, '')) }
        end
      end

      context 'new lines \n when <<' do
        subject { Table.new { |t| t.rows << ["a\nb"] } }

        expected = <<END
        +-----+
        | a b |
        +-----+
END
        describe '#to_s' do
          subject { super().to_s }
          it { is_expected.to eq(expected.gsub(/^(\s+)/, '')) }
        end
      end

      context 'new lines \r' do
        subject { Table.new { |t| t.rows = [["a\rb"]] } }

        expected = <<END
        +-----+
        | a b |
        +-----+
END
        describe '#to_s' do
          subject { super().to_s }
          it { is_expected.to eq(expected.gsub(/^(\s+)/, '')) }
        end
      end

      context 'new line symbol' do
        subject { Table.new(nil, use_new_line_symbol: true).tap { |t| t.rows = [["a\rb"]] } }

        expected = <<END
        +-----+
        | a⏎b |
        +-----+
END
        describe '#to_s' do
          subject { super().to_s }
          it { is_expected.to eq(expected.gsub(/^(\s+)/, '')) }
        end
      end

      context 'mutli calls to <<' do
        it 'works as well' do
          table = Table.new
          table.rows << %w{ a }
          table.rows << %w{ b }

          expected = <<END
          +---+
          | a |
          | b |
          +---+
END

          expect(table.to_s).to eq(expected.gsub(/^(\s+)/, ''))
        end
      end

      context 'when only heading' do
        subject { Table.new { |t| t.headings = %w{ head } } }

        describe '#to_s' do
          subject { super().to_s }
          it { is_expected.to eq("+------+\n| head |\n+------+\n+------+\n") }
        end
      end

      context 'when set contents after' do
        subject { Table.new.tap { |t| t.headings = %w{ head } } }

        describe '#to_s' do
          subject { super().to_s }
          it { is_expected.to eq("+------+\n| head |\n+------+\n+------+\n") }
        end
      end

      context 'with nil values' do
        subject { Table.new { |t| t.headings = %w{ head }; t.rows = [ [ nil ] ] } }

        describe '#to_s' do
          subject { super().to_s }
          it { is_expected.to eq("+------+\n| head |\n+------+\n|      |\n+------+\n") }
        end
      end

      context 'with nil values' do
        subject { Table.new { |t| t.headings = %w{ head1 head2 }; t.rows = [ [ nil, nil ] ] } }
        expected = <<END
        +-------+-------+
        | head1 | head2 |
        +-------+-------+
        |       |       |
        +-------+-------+
END
        describe '#to_s' do
          subject { super().to_s }
          it { is_expected.to eq(expected.gsub(/^(\s+)/, '')) }
        end
      end
    end
  end
end

describe String do
  describe '#twidth' do
    context 'Ｃ' do
      subject { 'Ｃ' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(2) }
      end
    end

    context 'ě' do
      subject { 'ě' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context 'ｌ' do
      subject { 'ｌ' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(2) }
      end
    end

    context 'ì' do
      subject { 'ì' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '☺️' do
      subject { '☺️' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '☺️☺️' do
      subject { '☺️☺️' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(2) }
      end
    end

    context '❤️' do
      subject { '❤️' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '√' do
      subject { '√' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '”' do
      subject { '”' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '“' do
      subject { '“' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '♍️' do
      subject { '♍️' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '♍️♍️' do
      subject { '♍️♍️' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(2) }
      end
    end

    context '☻' do
      subject { '☻' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '※' do
      subject { '※' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '◎' do
      subject { '◎' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '◆' do
      subject { '◆' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '‘' do
      subject { '‘' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '★ ’' do
      subject { '★ ’' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(3) }
      end
    end

    context '—' do
      subject { '—' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context 'special whitespace' do
      subject { ' ' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context ' ͡° ͜ʖ ͡°' do
      subject { ' ͡° ͜ʖ ͡°' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(6) }
      end
    end

    context '（¯﹃¯）' do
      subject { '（¯﹃¯）' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(8) }
      end
    end

    context '（）' do
      subject { '（）' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(4) }
      end
    end

    context '≥≤' do
      subject { '≥≤' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(2) }
      end
    end

    context '（≧∇≦）' do
      subject { '（≧∇≦）' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(7) }
      end
    end

    context '' do
      subject { '' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '❤' do
      subject { '❤' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '☺' do
      subject { '☺' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '╭(╯ε╰)╮' do
      subject { '╭(╯ε╰)╮' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(7) }
      end
    end

    context '_(:з)∠)_' do
      subject { '_(:з)∠)_' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(8) }
      end
    end

    context '→_→' do
      subject { '→_→' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(3) }
      end
    end

    context '☞' do
      subject { '☞' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context 'ë' do
      subject { 'ë' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '☔️' do
      subject { '☔️' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context "ϵ( 'Θ' )϶" do
      subject { "ϵ( 'Θ' )϶" }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(9) }
      end
    end

    context 'にΟΙ' do
      subject { 'にΟΙ' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(4) }
      end
    end

    context ' ̫' do
      subject { ' ̫' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '　' do
      subject { '　' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(2) }
      end
    end

    context '←' do
      subject { '←' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '¥' do
      subject { '¥' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context 'ó' do
      subject { 'ó' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '(˶‾᷄ ⁻̫ ‾᷅˵)' do
      subject { '(˶‾᷄ ⁻̫ ‾᷅˵)' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(9) }
      end
    end

    context '╥' do
      subject { '╥' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '⊙' do
      subject { '⊙' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '(｡･ω･｡)ﾉ♡' do
      subject { '(｡･ω･｡)ﾉ♡' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(9) }
      end
    end

    context '' do
      subject { '' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '👋' do
      subject { '👋' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '↓↓' do
      subject { '↓↓' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(2) }
      end
    end

    context '℃' do
      subject { '℃' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '(●✿∀✿●)' do
      subject { '(●✿∀✿●)' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(7) }
      end
    end

    context 'Д' do
      subject { 'Д' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '(´•̥̥̥ω•̥̥̥`)' do
      subject { '(´•̥̥̥ω•̥̥̥`)' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(7) }
      end
    end

    context ' ᷄' do
      subject { ' ᷄' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '‾' do
      subject { '‾' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '༼蛇精༽༄ ' do
      subject { '༼蛇精༽༄ ' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(8) }
      end
    end

    context '✌' do
      subject { '✌' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '(´Д` )' do
      subject { '(´Д` )' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(6) }
      end
    end

    context '゜∀)ノ' do
      subject { '゜∀)ノ' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(6) }
      end
    end

    context '⬇⬇⬇⬇' do
      subject { '⬇⬇⬇⬇' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(4) }
      end
    end

    context 'ヽ(#`Д´)ﾉ' do
      subject { 'ヽ(#`Д´)ﾉ' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(9) }
      end
    end

    context '～٩(๑ᵒ̴̶̷͈᷄ᗨᵒ̴̶̷͈᷅)و' do
      subject { '～٩(๑ᵒ̴̶̷͈᷄ᗨᵒ̴̶̷͈᷅)و' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(10) }
      end
    end

    context '😂' do
      subject { '😂' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '⊙▽⊙' do
      subject { '⊙▽⊙' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(3) }
      end
    end

    context '✖️✖️' do
      subject { '✖️✖️' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(2) }
      end
    end

    context '☁' do
      subject { '☁' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '( ・᷄ ᵌ・᷅ )' do
      subject { '( ・᷄ ᵌ・᷅ )' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(10) }
      end
    end

    context '(☆_☆)Y(^_^)Y ♪─Ｏ（≧∇≦）Ｏ─♪' do
      subject { '(☆_☆)Y(^_^)Y ♪─Ｏ（≧∇≦）Ｏ─♪' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(28) }
      end
    end

    context '12～★ 今天新换的 (๑¯ิε ¯ิ๑）' do
      subject { '12～★ 今天新换的 (๑¯ิε ¯ิ๑）' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(26) }
      end
    end

    context '☀' do
      subject { '☀' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '☀︎' do
      subject { '☀︎' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '(´･_･`)' do
      subject { '(´･_･`)' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(7) }
      end
    end

    context '୧⃛(๑⃙⃘◡̈๑⃙⃘)୨⃛' do
      subject { '୧⃛(๑⃙⃘◡̈๑⃙⃘)୨⃛' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(7) }
      end
    end

    context '❓⁉️' do
      subject { '❓⁉️' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(2) }
      end
    end

    context '⬇️⬇️⬇️⬇️⬇️…🌚！！！😰😤😤' do
      subject { '⬇️⬇️⬇️⬇️⬇️…🌚！！！😰😤😤' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(16) }
      end
    end

    context '！' do
      subject { '！' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(2) }
      end
    end

    context '～' do
      subject { '～' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(2) }
      end
    end

    context '(˘̩̩̩ε˘̩ƪ)' do
      subject { '(˘̩̩̩ε˘̩ƪ)' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(6) }
      end
    end

    context 'ʕ •ᴥ•ʔ' do
      subject { 'ʕ •ᴥ•ʔ' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(6) }
      end
    end

    context '´●＿●`' do
      subject { '´●＿●`' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(6) }
      end
    end

    context '＿' do
      subject { '＿' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(2) }
      end
    end

    context '`' do
      subject { '`' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '´' do
      subject { '´' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '☆ゝ' do
      subject { '☆ゝ' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(3) }
      end
    end

    context '(͏ ˉ ꈊ ˉ)✧˖°' do
      subject { "(͏ ˉ ꈊ ˉ)✧˖°" }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(12) }
      end
    end

    context '₍₍ (̨̡ ᗣ )̧̢ ₎₎' do
      subject { '₍₍ (̨̡ ᗣ )̧̢ ₎₎' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(11) }
      end
    end

    context '♚' do
      subject { '♚' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '(●°u°●)​ 」' do
      subject { '(●°u°●)​ 」' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(11) }
      end
    end

    context '」' do
      subject { '」' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(2) }
      end
    end

    context '​​' do
      subject { '​' } # 8203

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context 'ಥ_ಥ' do
      subject { 'ಥ_ಥ' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(3) }
      end
    end

    context '♪٩(´▽｀๑)۶ ' do
      subject { '♪٩(´▽｀๑)۶ ' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(11) }
      end
    end

    context 'ಠ_ಠ' do
      subject { 'ಠ_ಠ' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(3) }
      end
    end

    context '(ᵒ̤̑ ₀̑ ᵒ̤̑)' do
      subject { '(ᵒ̤̑ ₀̑ ᵒ̤̑)' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(7) }
      end
    end

    context '눈_눈' do
      subject { '눈_눈' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(5) }
      end
    end

    context '' do
      subject { '' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '((((；ﾟДﾟ)))))))' do
      subject { '((((；ﾟДﾟ)))))))' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(16) }
      end
    end

    context '（∮∧∮）' do
      subject { '（∮∧∮）' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(7) }
      end
    end

    context 'ヽ(￣д￣;)ノ' do
      subject { 'ヽ(￣д￣;)ノ' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(12) }
      end
    end

    context '(Ծ‸ Ծ )' do
      subject { '(Ծ‸ Ծ )' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(7) }
      end
    end

    context '(۶ૈ ۜ ᵒ̌▱๋ᵒ̌ )۶ૈ=͟͟͞͞ ⌨' do
      subject { '(۶ૈ ۜ ᵒ̌▱๋ᵒ̌ )۶ૈ=͟͟͞͞ ⌨' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(13) }
      end
    end

    context '(๑˃̵ᴗ˂̵)و ' do
      subject { '(๑˃̵ᴗ˂̵)و ' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(8) }
      end
    end

    context '嘤ू(ʚ̴̶̷́ .̠ ʚ̴̶̷̥̀ ू) ' do
      subject { '嘤ू(ʚ̴̶̷́ .̠ ʚ̴̶̷̥̀ ू) ' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(11) }
      end
    end

    context '⁽⁽٩(๑˃̶͈̀  ˂̶͈́)۶⁾⁾' do
      subject { '⁽⁽٩(๑˃̶͈̀  ˂̶͈́)۶⁾⁾' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(13) }
      end
    end

    context '(ᵒ̤̑ ₀̑ ᵒ̤̑)' do
      subject { '(ᵒ̤̑ ₀̑ ᵒ̤̑)' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(7) }
      end
    end

    context 'AÏcha' do
      subject { 'AÏcha' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(5) }
      end
    end

    context '(ᵒ̤̑ ₀̑ ᵒ̤̑)' do
      subject { '(ᵒ̤̑ ₀̑ ᵒ̤̑)' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(7) }
      end
    end

    context '(╯°Д°)╯︵ ┻━┻ ' do
      subject { '(╯°Д°)╯︵ ┻━┻ ' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(14) }
      end
    end

    context '┭┮﹏┭┮' do
      subject { '┭┮﹏┭┮' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(6) }
      end
    end

    context '=△=' do
      subject { '=△=' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(3) }
      end
    end

    context ' (ؓؒؒؑؑؖؔؓؒؐؐ⁼̴̀ωؘؙؖؕؔؓؒؑؐؕ⁼̴̀ )✧' do
      subject { ' (ؓؒؒؑؑؖؔؓؒؐؐ⁼̴̀ωؘؙؖؕؔؓؒؑؐؕ⁼̴̀ )✧' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(8) }
      end
    end

    context '(¦3[____]' do
      subject { '(¦3[____]' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(9) }
      end
    end

    context '( •̥́ ˍ •̀ू )' do
      subject { '( •̥́ ˍ •̀ू )' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(9) }
      end
    end

    context 'Σ（ﾟдﾟlll） ' do
      subject { 'Σ（ﾟдﾟlll） ' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(12) }
      end
    end

    context '☁︎' do
      subject { '☁︎' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '▀ ▄ ‖ █ ‖▌‖' do
      subject { '▀ ▄ ‖ █ ‖▌‖' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(11) }
      end
    end

    context 'にこにー♡' do
      subject { 'にこにー♡' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(9) }
      end
    end

    context 'Наташа' do
      subject { 'Наташа' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(6) }
      end
    end

    context '(╯°□°）╯︵' do
      subject { '(╯°□°）╯︵' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(10) }
      end
    end

    context 'Facebig(((o(*ﾟ▽ﾟ*)o)))' do
      subject { 'Facebig(((o(*ﾟ▽ﾟ*)o)))' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(22) }
      end
    end

    context '♥' do
      subject { '♥' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '❥' do
      subject { '❥' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '❀' do
      subject { '❀' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '∩' do
      subject { '∩' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '╳' do
      subject { '╳' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '❄️' do
      subject { '❄️' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '❦' do
      subject { '❦' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '✌️' do
      subject { '✌️' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '✘' do
      subject { '✘' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '×' do
      subject { '×' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '♨️' do
      subject { '♨️' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '✪' do
      subject { '✪' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '☂' do
      subject { '☂' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '6⃣' do
      subject { '6⃣' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '▼' do
      subject { '▼' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '˚' do
      subject { '˚' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '₊' do
      subject { '₊' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '♻️' do
      subject { '♻️' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '♒️' do
      subject { '♒️' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '±' do
      subject { '±' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '✏' do
      subject { '✏' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '∪' do
      subject { '∪' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '♬' do
      subject { '♬' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '☜☞' do
      subject { '☜☞' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(2) }
      end
    end

    context '' do
      subject { '' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '✏️' do
      subject { '✏️' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '┐' do
      subject { '┐' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '┌' do
      subject { '┌' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '🇨🇳' do
      subject { '🇨🇳' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '' do
      subject { '' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '✔' do
      subject { '✔' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context 'ฅ' do
      subject { 'ฅ' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '○' do
      subject { '○' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '′' do
      subject { '′' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '☁️' do
      subject { '☁️' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context 'ℕᏐᎶℍᎢ' do
      subject { 'ℕᏐᎶℍᎢ' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(5) }
      end
    end

    context '✈️' do
      subject { '✈️' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '☀️' do
      subject { '☀️' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context 'ಠ' do
      subject { 'ಠ' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context 'ರೃ' do
      subject { 'ರೃ' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(2) }
      end
    end

    context 'ä' do
      subject { 'ä' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '♥️' do
      subject { '♥️' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '❶' do
      subject { '❶' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '☘' do
      subject { '☘' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '⚡️' do
      subject { '⚡️' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '✔️' do
      subject { '✔️' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '🇰🇷' do
      subject { '🇰🇷' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context 'ã' do
      subject { 'ã' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '✔' do
      subject { '✔' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '⌛️' do
      subject { '⌛️' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '♂' do
      subject { '♂' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context 'ｪ' do
      subject { 'ｪ' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context '㊙️' do
      subject { '㊙️' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(2) }
      end
    end

    context 'Ⅱ' do
      subject { 'Ⅱ' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context 'à' do
      subject { 'à' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end

    context 'ö' do
      subject { 'ö' }

      describe '#twidth' do
        subject { super().twidth }
        it { is_expected.to eq(1) }
      end
    end
  end
end
