require "spec_helper"

module Terminal
  describe Table do
    it { should respond_to :to_s }

    describe '#to_s' do
      context 'when empty' do
        subject { Table.new }
        its(:to_s) { should == "++\n++\n" }
      end

      context 'when only heading' do
        subject { Table.new { |t| t.headings = %w{ head } } }
        its(:to_s) { should == "+------+\n| head |\n+------+\n+------+\n" }
      end
    end
  end
end
