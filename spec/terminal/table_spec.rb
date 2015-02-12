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
      it { should respond_to :special_tokens }
    end

    it { should respond_to :to_s }

    describe 'initialize with array of array' do
      let(:array) { [%w{ hello 1 }, %w{ world 2 } ] }
      subject { Table.new(array) }

      expected = <<END
      +-------+---+
      | hello | 1 |
      | world | 2 |
      +-------+---+
END
      its(:to_s) { should == expected.gsub(/^(\s+)/, '') }
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
      its(:to_s) { should == expected.gsub(/^(\s+)/, '') }
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
      its(:to_s) { should == expected.gsub(/^(\s+)/, '') }
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
      its(:to_s) { should == expected.gsub(/^(\s+)/, '') }
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
      its(:to_s) { should == expected.gsub(/^(\s+)/, '') }
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
      its(:to_s) { should == expected.gsub(/^(\s+)/, '') }
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
      its(:to_s) { should == expected.gsub(/^(\s+)/, '') }
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
      its(:to_s) { should == expected.gsub(/^(\s+)/, '') }
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
      its(:to_s) { should == expected.gsub(/^(\s+)/, '') }
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
      its(:to_s) { should == expected.gsub(/^(\s+)/, '') }
    end

    describe '#to_s' do
      context 'when empty' do
        subject { Table.new }
        its(:to_s) { should == "++\n++\n" }
      end

      context 'new lines \n' do
        subject { Table.new { |t| t.rows = [["a\nb"]] } }

        expected = <<END
        +-----+
        | a b |
        +-----+
END
        its(:to_s) { should == expected.gsub(/^(\s+)/, '') }
      end

      context 'new lines \n when <<' do
        subject { Table.new { |t| t.rows << ["a\nb"] } }

        expected = <<END
        +-----+
        | a b |
        +-----+
END
        its(:to_s) { should == expected.gsub(/^(\s+)/, '') }
      end

      context 'new lines \r' do
        subject { Table.new { |t| t.rows = [["a\rb"]] } }

        expected = <<END
        +-----+
        | a b |
        +-----+
END
        its(:to_s) { should == expected.gsub(/^(\s+)/, '') }
      end

      context 'new line symbol' do
        subject { Table.new(nil, use_new_line_symbol: true).tap { |t| t.rows = [["a\rb"]] } }

        expected = <<END
        +-----+
        | a⏎b |
        +-----+
END
        its(:to_s) { should == expected.gsub(/^(\s+)/, '') }
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

          table.to_s.should == expected.gsub(/^(\s+)/, '')
        end
      end

      context 'when only heading' do
        subject { Table.new { |t| t.headings = %w{ head } } }
        its(:to_s) { should == "+------+\n| head |\n+------+\n+------+\n" }
      end

      context 'when set contents after' do
        subject { Table.new.tap { |t| t.headings = %w{ head } } }
        its(:to_s) { should == "+------+\n| head |\n+------+\n+------+\n" }
      end

      context 'with nil values' do
        subject { Table.new { |t| t.headings = %w{ head }; t.rows = [ [ nil ] ] } }
        its(:to_s) { should == "+------+\n| head |\n+------+\n|      |\n+------+\n" }
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
        its(:to_s) { should == expected.gsub(/^(\s+)/, '') }
      end
    end
  end
end

describe String do
  describe '#twidth' do
    context 'Ｃ' do
      subject { 'Ｃ' }
      its(:twidth) { should == 2 }
    end

    context 'ě' do
      subject { 'ě' }
      its(:twidth) { should == 1 }
    end

    context 'ｌ' do
      subject { 'ｌ' }
      its(:twidth) { should == 2 }
    end

    context 'ì' do
      subject { 'ì' }
      its(:twidth) { should == 1 }
    end

    context '☺️' do
      subject { '☺️' }
      its(:twidth) { should == 1 }
    end

    context '☺️☺️' do
      subject { '☺️☺️' }
      its(:twidth) { should == 2 }
    end

    context '❤️' do
      subject { '❤️' }
      its(:twidth) { should == 1 }
    end

    context '√' do
      subject { '√' }
      its(:twidth) { should == 1 }
    end

    context '”' do
      subject { '”' }
      its(:twidth) { should == 1 }
    end

    context '“' do
      subject { '“' }
      its(:twidth) { should == 1 }
    end

    context '♍️' do
      subject { '♍️' }
      its(:twidth) { should == 1 }
    end

    context '♍️♍️' do
      subject { '♍️♍️' }
      its(:twidth) { should == 2 }
    end

    context '☻' do
      subject { '☻' }
      its(:twidth) { should == 1 }
    end

    context '※' do
      subject { '※' }
      its(:twidth) { should == 1 }
    end

    context '◎' do
      subject { '◎' }
      its(:twidth) { should == 1 }
    end

    context '◆' do
      subject { '◆' }
      its(:twidth) { should == 1 }
    end

    context '‘' do
      subject { '‘' }
      its(:twidth) { should == 1 }
    end

    context '★ ’' do
      subject { '★ ’' }
      its(:twidth) { should == 3 }
    end

    context '—' do
      subject { '—' }
      its(:twidth) { should == 1 }
    end

    context 'special whitespace' do
      subject { ' ' }
      its(:twidth) { should == 1 }
    end

    context ' ͡° ͜ʖ ͡°' do
      subject { ' ͡° ͜ʖ ͡°' }
      its(:twidth) { should == 6 }
    end

    context '（¯﹃¯）' do
      subject { '（¯﹃¯）' }
      its(:twidth) { should == 8 }
    end

    context '（）' do
      subject { '（）' }
      its(:twidth) { should == 4 }
    end

    context '≥≤' do
      subject { '≥≤' }
      its(:twidth) { should == 2 }
    end

    context '（≧∇≦）' do
      subject { '（≧∇≦）' }
      its(:twidth) { should == 7 }
    end

    context '' do
      subject { '' }
      its(:twidth) { should == 1 }
    end

    context '❤' do
      subject { '❤' }
      its(:twidth) { should == 1 }
    end

    context '☺' do
      subject { '☺' }
      its(:twidth) { should == 1 }
    end

    context '╭(╯ε╰)╮' do
      subject { '╭(╯ε╰)╮' }
      its(:twidth) { should == 7 }
    end

    context '_(:з)∠)_' do
      subject { '_(:з)∠)_' }
      its(:twidth) { should == 8 }
    end

    context '→_→' do
      subject { '→_→' }
      its(:twidth) { should == 3 }
    end

    context '☞' do
      subject { '☞' }
      its(:twidth) { should == 1 }
    end

    context 'ë' do
      subject { 'ë' }
      its(:twidth) { should == 1 }
    end

    context '☔️' do
      subject { '☔️' }
      its(:twidth) { should == 1 }
    end

    context "ϵ( 'Θ' )϶" do
      subject { "ϵ( 'Θ' )϶" }
      its(:twidth) { should == 9 }
    end

    context 'にΟΙ' do
      subject { 'にΟΙ' }
      its(:twidth) { should == 4 }
    end

    context ' ̫' do
      subject { ' ̫' }
      its(:twidth) { should == 1 }
    end

    context '　' do
      subject { '　' }
      its(:twidth) { should == 2 }
    end

    context '←' do
      subject { '←' }
      its(:twidth) { should == 1 }
    end

    context '¥' do
      subject { '¥' }
      its(:twidth) { should == 1 }
    end

    context 'ó' do
      subject { 'ó' }
      its(:twidth) { should == 1 }
    end

    context '(˶‾᷄ ⁻̫ ‾᷅˵)' do
      subject { '(˶‾᷄ ⁻̫ ‾᷅˵)' }
      its(:twidth) { should == 9 }
    end

    context '╥' do
      subject { '╥' }
      its(:twidth) { should == 1 }
    end

    context '⊙' do
      subject { '⊙' }
      its(:twidth) { should == 1 }
    end

    context '(｡･ω･｡)ﾉ♡' do
      subject { '(｡･ω･｡)ﾉ♡' }
      its(:twidth) { should == 9 }
    end

    context '' do
      subject { '' }
      its(:twidth) { should == 1 }
    end

    context '👋' do
      subject { '👋' }
      its(:twidth) { should == 1 }
    end

    context '↓↓' do
      subject { '↓↓' }
      its(:twidth) { should == 2 }
    end

    context '℃' do
      subject { '℃' }
      its(:twidth) { should == 1 }
    end

    context '(●✿∀✿●)' do
      subject { '(●✿∀✿●)' }
      its(:twidth) { should == 7 }
    end

    context 'Д' do
      subject { 'Д' }
      its(:twidth) { should == 1 }
    end

    context '(´•̥̥̥ω•̥̥̥`)' do
      subject { '(´•̥̥̥ω•̥̥̥`)' }
      its(:twidth) { should == 7 }
    end

    context ' ᷄' do
      subject { ' ᷄' }
      its(:twidth) { should == 1 }
    end

    context '‾' do
      subject { '‾' }
      its(:twidth) { should == 1 }
    end

    context '༼蛇精༽༄ ' do
      subject { '༼蛇精༽༄ ' }
      its(:twidth) { should == 8 }
    end

    context '✌' do
      subject { '✌' }
      its(:twidth) { should == 1 }
    end

    context '(´Д` )' do
      subject { '(´Д` )' }
      its(:twidth) { should == 6 }
    end

    context '゜∀)ノ' do
      subject { '゜∀)ノ' }
      its(:twidth) { should == 6 }
    end

    context '⬇⬇⬇⬇' do
      subject { '⬇⬇⬇⬇' }
      its(:twidth) { should == 4 }
    end

    context 'ヽ(#`Д´)ﾉ' do
      subject { 'ヽ(#`Д´)ﾉ' }
      its(:twidth) { should == 9 }
    end

    context '～٩(๑ᵒ̴̶̷͈᷄ᗨᵒ̴̶̷͈᷅)و' do
      subject { '～٩(๑ᵒ̴̶̷͈᷄ᗨᵒ̴̶̷͈᷅)و' }
      its(:twidth) { should == 10 }
    end

    context '😂' do
      subject { '😂' }
      its(:twidth) { should == 1 }
    end

    context '⊙▽⊙' do
      subject { '⊙▽⊙' }
      its(:twidth) { should == 3 }
    end

    context '✖️✖️' do
      subject { '✖️✖️' }
      its(:twidth) { should == 2 }
    end

    context '☁' do
      subject { '☁' }
      its(:twidth) { should == 1 }
    end

    context '( ・᷄ ᵌ・᷅ )' do
      subject { '( ・᷄ ᵌ・᷅ )' }
      its(:twidth) { should == 10 }
    end

    context '(☆_☆)Y(^_^)Y ♪─Ｏ（≧∇≦）Ｏ─♪' do
      subject { '(☆_☆)Y(^_^)Y ♪─Ｏ（≧∇≦）Ｏ─♪' }
      its(:twidth) { should == 28 }
    end

    context '12～★ 今天新换的 (๑¯ิε ¯ิ๑）' do
      subject { '12～★ 今天新换的 (๑¯ิε ¯ิ๑）' }
      its(:twidth) { should == 26 }
    end

    context '☀' do
      subject { '☀' }
      its(:twidth) { should == 1 }
    end

    context '☀︎' do
      subject { '☀︎' }
      its(:twidth) { should == 1 }
    end

    context '(´･_･`)' do
      subject { '(´･_･`)' }
      its(:twidth) { should == 7 }
    end

    context '୧⃛(๑⃙⃘◡̈๑⃙⃘)୨⃛' do
      subject { '୧⃛(๑⃙⃘◡̈๑⃙⃘)୨⃛' }
      its(:twidth) { should == 7 }
    end

    context '❓⁉️' do
      subject { '❓⁉️' }
      its(:twidth) { should == 2 }
    end

    context '⬇️⬇️⬇️⬇️⬇️…🌚！！！😰😤😤' do
      subject { '⬇️⬇️⬇️⬇️⬇️…🌚！！！😰😤😤' }
      its(:twidth) { should == 16 }
    end

    context '！' do
      subject { '！' }
      its(:twidth) { should == 2 }
    end

    context '～' do
      subject { '～' }
      its(:twidth) { should == 2 }
    end

    context '(˘̩̩̩ε˘̩ƪ)' do
      subject { '(˘̩̩̩ε˘̩ƪ)' }
      its(:twidth) { should == 6 }
    end

    context 'ʕ •ᴥ•ʔ' do
      subject { 'ʕ •ᴥ•ʔ' }
      its(:twidth) { should == 6 }
    end

    context '´●＿●`' do
      subject { '´●＿●`' }
      its(:twidth) { should == 6 }
    end

    context '＿' do
      subject { '＿' }
      its(:twidth) { should == 2 }
    end

    context '`' do
      subject { '`' }
      its(:twidth) { should == 1 }
    end

    context '´' do
      subject { '´' }
      its(:twidth) { should == 1 }
    end

    context '☆ゝ' do
      subject { '☆ゝ' }
      its(:twidth) { should == 3 }
    end

    context '(͏ ˉ ꈊ ˉ)✧˖°' do
      subject { "(͏ ˉ ꈊ ˉ)✧˖°" }
      its(:twidth) { should == 12 }
    end

    context '₍₍ (̨̡ ᗣ )̧̢ ₎₎' do
      subject { '₍₍ (̨̡ ᗣ )̧̢ ₎₎' }
      its(:twidth) { should == 11 }
    end

    context '♚' do
      subject { '♚' }
      its(:twidth) { should == 1 }
    end

    context '(●°u°●)​ 」' do
      subject { '(●°u°●)​ 」' }
      its(:twidth) { should == 11 }
    end

    context '」' do
      subject { '」' }
      its(:twidth) { should == 2 }
    end

    context '​​' do
      subject { '​' } # 8203
      its(:twidth) { should == 1 }
    end

    context 'ಥ_ಥ' do
      subject { 'ಥ_ಥ' }
      its(:twidth) { should == 3 }
    end

    context '♪٩(´▽｀๑)۶ ' do
      subject { '♪٩(´▽｀๑)۶ ' }
      its(:twidth) { should == 11 }
    end

    context 'ಠ_ಠ' do
      subject { 'ಠ_ಠ' }
      its(:twidth) { should == 3 }
    end

    context '(ᵒ̤̑ ₀̑ ᵒ̤̑)' do
      subject { '(ᵒ̤̑ ₀̑ ᵒ̤̑)' }
      its(:twidth) { should == 7 }
    end

    context '눈_눈' do
      subject { '눈_눈' }
      its(:twidth) { should == 5 }
    end

    context '' do
      subject { '' }
      its(:twidth) { should == 1 }
    end

    context '((((；ﾟДﾟ)))))))' do
      subject { '((((；ﾟДﾟ)))))))' }
      its(:twidth) { should == 16 }
    end

    context '（∮∧∮）' do
      subject { '（∮∧∮）' }
      its(:twidth) { should == 7 }
    end

    context 'ヽ(￣д￣;)ノ' do
      subject { 'ヽ(￣д￣;)ノ' }
      its(:twidth) { should == 12 }
    end

    context '(Ծ‸ Ծ )' do
      subject { '(Ծ‸ Ծ )' }
      its(:twidth) { should == 7 }
    end

    context '(۶ૈ ۜ ᵒ̌▱๋ᵒ̌ )۶ૈ=͟͟͞͞ ⌨' do
      subject { '(۶ૈ ۜ ᵒ̌▱๋ᵒ̌ )۶ૈ=͟͟͞͞ ⌨' }
      its(:twidth) { should == 13 }
    end

    context '(๑˃̵ᴗ˂̵)و ' do
      subject { '(๑˃̵ᴗ˂̵)و ' }
      its(:twidth) { should == 8 }
    end

    context '嘤ू(ʚ̴̶̷́ .̠ ʚ̴̶̷̥̀ ू) ' do
      subject { '嘤ू(ʚ̴̶̷́ .̠ ʚ̴̶̷̥̀ ू) ' }
      its(:twidth) { should == 11 }
    end

    context '⁽⁽٩(๑˃̶͈̀  ˂̶͈́)۶⁾⁾' do
      subject { '⁽⁽٩(๑˃̶͈̀  ˂̶͈́)۶⁾⁾' }
      its(:twidth) { should == 13 }
    end

    context '(ᵒ̤̑ ₀̑ ᵒ̤̑)' do
      subject { '(ᵒ̤̑ ₀̑ ᵒ̤̑)' }
      its(:twidth) { should == 7 }
    end

    context 'AÏcha' do
      subject { 'AÏcha' }
      its(:twidth) { should == 5 }
    end

    context '(ᵒ̤̑ ₀̑ ᵒ̤̑)' do
      subject { '(ᵒ̤̑ ₀̑ ᵒ̤̑)' }
      its(:twidth) { should == 7 }
    end

    context '(╯°Д°)╯︵ ┻━┻ ' do
      subject { '(╯°Д°)╯︵ ┻━┻ ' }
      its(:twidth) { should == 14 }
    end

    context '┭┮﹏┭┮' do
      subject { '┭┮﹏┭┮' }
      its(:twidth) { should == 6 }
    end

    context '=△=' do
      subject { '=△=' }
      its(:twidth) { should == 3 }
    end

    context ' (ؓؒؒؑؑؖؔؓؒؐؐ⁼̴̀ωؘؙؖؕؔؓؒؑؐؕ⁼̴̀ )✧' do
      subject { ' (ؓؒؒؑؑؖؔؓؒؐؐ⁼̴̀ωؘؙؖؕؔؓؒؑؐؕ⁼̴̀ )✧' }
      its(:twidth) { should == 8 }
    end

    context '(¦3[____]' do
      subject { '(¦3[____]' }
      its(:twidth) { should == 9 }
    end

    context '( •̥́ ˍ •̀ू )' do
      subject { '( •̥́ ˍ •̀ू )' }
      its(:twidth) { should == 9 }
    end

    context 'Σ（ﾟдﾟlll） ' do
      subject { 'Σ（ﾟдﾟlll） ' }
      its(:twidth) { should == 12 }
    end

    context '☁︎' do
      subject { '☁︎' }
      its(:twidth) { should == 1 }
    end

    context '▀ ▄ ‖ █ ‖▌‖' do
      subject { '▀ ▄ ‖ █ ‖▌‖' }
      its(:twidth) { should == 11 }
    end

    context 'にこにー♡' do
      subject { 'にこにー♡' }
      its(:twidth) { should == 9 }
    end

    context 'Наташа' do
      subject { 'Наташа' }
      its(:twidth) { should == 6 }
    end

    context '(╯°□°）╯︵' do
      subject { '(╯°□°）╯︵' }
      its(:twidth) { should == 10 }
    end

    context 'Facebig(((o(*ﾟ▽ﾟ*)o)))' do
      subject { 'Facebig(((o(*ﾟ▽ﾟ*)o)))' }
      its(:twidth) { should == 22 }
    end

    context '♥' do
      subject { '♥' }
      its(:twidth) { should == 1 }
    end

    context '❥' do
      subject { '❥' }
      its(:twidth) { should == 1 }
    end

    context '❀' do
      subject { '❀' }
      its(:twidth) { should == 1 }
    end

    context '∩' do
      subject { '∩' }
      its(:twidth) { should == 1 }
    end

    context '╳' do
      subject { '╳' }
      its(:twidth) { should == 1 }
    end

    context '❄️' do
      subject { '❄️' }
      its(:twidth) { should == 1 }
    end

    context '❦' do
      subject { '❦' }
      its(:twidth) { should == 1 }
    end

    context '✌️' do
      subject { '✌️' }
      its(:twidth) { should == 1 }
    end

    context '✘' do
      subject { '✘' }
      its(:twidth) { should == 1 }
    end

    context '×' do
      subject { '×' }
      its(:twidth) { should == 1 }
    end

    context '♨️' do
      subject { '♨️' }
      its(:twidth) { should == 1 }
    end

    context '✪' do
      subject { '✪' }
      its(:twidth) { should == 1 }
    end

    context '☂' do
      subject { '☂' }
      its(:twidth) { should == 1 }
    end

    context '6⃣' do
      subject { '6⃣' }
      its(:twidth) { should == 1 }
    end

    context '▼' do
      subject { '▼' }
      its(:twidth) { should == 1 }
    end

    context '˚' do
      subject { '˚' }
      its(:twidth) { should == 1 }
    end

    context '₊' do
      subject { '₊' }
      its(:twidth) { should == 1 }
    end

    context '♻️' do
      subject { '♻️' }
      its(:twidth) { should == 1 }
    end

    context '♒️' do
      subject { '♒️' }
      its(:twidth) { should == 1 }
    end

    context '±' do
      subject { '±' }
      its(:twidth) { should == 1 }
    end

    context '✏' do
      subject { '✏' }
      its(:twidth) { should == 1 }
    end

    context '∪' do
      subject { '∪' }
      its(:twidth) { should == 1 }
    end

    context '♬' do
      subject { '♬' }
      its(:twidth) { should == 1 }
    end

    context '☜☞' do
      subject { '☜☞' }
      its(:twidth) { should == 2 }
    end

    context '' do
      subject { '' }
      its(:twidth) { should == 1 }
    end

    context '✏️' do
      subject { '✏️' }
      its(:twidth) { should == 1 }
    end

    context '┐' do
      subject { '┐' }
      its(:twidth) { should == 1 }
    end

    context '┌' do
      subject { '┌' }
      its(:twidth) { should == 1 }
    end

    context '🇨🇳' do
      subject { '🇨🇳' }
      its(:twidth) { should == 1 }
    end

    context '' do
      subject { '' }
      its(:twidth) { should == 1 }
    end

    context '✔' do
      subject { '✔' }
      its(:twidth) { should == 1 }
    end

    context 'ฅ' do
      subject { 'ฅ' }
      its(:twidth) { should == 1 }
    end

    context '○' do
      subject { '○' }
      its(:twidth) { should == 1 }
    end

    context '′' do
      subject { '′' }
      its(:twidth) { should == 1 }
    end

    context '☁️' do
      subject { '☁️' }
      its(:twidth) { should == 1 }
    end

    context 'ℕᏐᎶℍᎢ' do
      subject { 'ℕᏐᎶℍᎢ' }
      its(:twidth) { should == 5 }
    end

    context '✈️' do
      subject { '✈️' }
      its(:twidth) { should == 1 }
    end

    context '☀️' do
      subject { '☀️' }
      its(:twidth) { should == 1 }
    end

    context 'ಠ' do
      subject { 'ಠ' }
      its(:twidth) { should == 1 }
    end

    context 'ರೃ' do
      subject { 'ರೃ' }
      its(:twidth) { should == 2 }
    end

    context 'ä' do
      subject { 'ä' }
      its(:twidth) { should == 1 }
    end

    context '♥️' do
      subject { '♥️' }
      its(:twidth) { should == 1 }
    end

    context '❶' do
      subject { '❶' }
      its(:twidth) { should == 1 }
    end

    context '☘' do
      subject { '☘' }
      its(:twidth) { should == 1 }
    end

    context '⚡️' do
      subject { '⚡️' }
      its(:twidth) { should == 1 }
    end

    context '✔️' do
      subject { '✔️' }
      its(:twidth) { should == 1 }
    end

    context '🇰🇷' do
      subject { '🇰🇷' }
      its(:twidth) { should == 1 }
    end

    context 'ã' do
      subject { 'ã' }
      its(:twidth) { should == 1 }
    end

    context '✔' do
      subject { '✔' }
      its(:twidth) { should == 1 }
    end

    context '⌛️' do
      subject { '⌛️' }
      its(:twidth) { should == 1 }
    end

    context '♂' do
      subject { '♂' }
      its(:twidth) { should == 1 }
    end

    context 'ｪ' do
      subject { 'ｪ' }
      its(:twidth) { should == 1 }
    end

    context '㊙️' do
      subject { '㊙️' }
      its(:twidth) { should == 2 }
    end

    context 'Ⅱ' do
      subject { 'Ⅱ' }
      its(:twidth) { should == 1 }
    end
  end
end
