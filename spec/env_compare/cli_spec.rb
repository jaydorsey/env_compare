# frozen_string_literal: true

RSpec.describe EnvCompare::Cli do
  describe '#version' do
    it 'shows version' do
      expect(STDOUT).to receive(:puts).with(EnvCompare::VERSION)

      described_class.start(['version'])
    end
  end
end
