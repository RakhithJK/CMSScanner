require 'spec_helper'
require 'dummy_finders'

describe CMSScanner::Finder::Finders do

  subject(:finders) { described_class.new }

  describe '#run' do
    let(:target)  { 'target' }
    let(:finding) { CMSScanner::Finder::Finding }
    let(:expected_passive) do
      [
        finding.new('test', method: 'DummyFinder (passive detection)'),
        finding.new('spotted', method: 'NoAggressiveResult (passive detection)', confidence: 10)
      ]
    end

    before do
      finders << CMSScanner::Finder::DummyFinder.new(target) <<
                 CMSScanner::Finder::NoAggressiveResult.new(target)

      @found = finders.run(mode)

      expect(@found).to be_a(CMSScanner::Finder::Findings)

      @found.each { |f| expect(f).to be_a finding }
    end

    context 'when :passive mode' do
      let(:mode) { :passive }

      it 'returns 2 results' do
        expect(@found.size).to eq 2
        expect(@found.first).to eql expected_passive.first
        expect(@found.last).to eql expected_passive.last
      end
    end

    context 'when :aggressive mode' do
      let(:mode) { :aggressive }

      it 'returns 1 result' do
        expect(@found.size).to eq 1
        expect(@found.first).to eql finding.new('test', method: 'override', confidence: 100)
      end
    end

    context 'when :mixed mode' do
      let(:mode) { :mixed }

      it 'returns 2 results' do
        expect(@found.size).to eq 2
        expect(@found.first).to eql expected_passive.first
        expect(@found.last).to eql expected_passive.last
      end
    end
  end

  describe '#symbols_from_mode' do
    after { expect(finders.symbols_from_mode(@mode)).to eq @expected }

    context 'when :mixed' do
      it 'returns [:passive, :aggressive]' do
        @mode     = :mixed
        @expected = [:passive, :aggressive]
      end
    end

    context 'when :passive or :aggresssive' do
      [:passive, :aggressive].each do |symbol|
        it 'returns it in an array' do
          @mode     = symbol
          @expected = [*symbol]
        end
      end
    end

    context 'otherwise' do
      it 'returns []' do
        @mode     = :unallowed
        @expected = []
      end
    end
  end

  describe '#findings' do
    it 'returns a Findings object' do
      expect(finders.findings).to be_a CMSScanner::Finder::Findings
    end
  end

end
