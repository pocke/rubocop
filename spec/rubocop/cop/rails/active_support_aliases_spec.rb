# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Rails::ActiveSupportAliases do
  subject(:cop) { described_class.new }

  describe 'String' do
    describe '#starts_with?' do
      it 'is registered as an offence' do
        inspect_source(cop, "'some_string'.starts_with?('prefix')")
        expect(cop.offenses.size).to eq(1)
        expect(cop.messages)
          .to eq(['Use `start_with?` instead of `starts_with?`.'])
      end

      it 'is autocorrected' do
        new_source = autocorrect_source(
          cop, "'some_string'.starts_with?('prefix')"
        )
        expect(new_source).to eq "'some_string'.start_with?('prefix')"
      end
    end

    describe '#start_with?' do
      it 'is not registered as an offense' do
        inspect_source(cop, "'some_string'.start_with?('prefix')")
        expect(cop.offenses.size).to eq(0)
      end
    end

    describe '#ends_with?' do
      it 'it is registered as an offense' do
        inspect_source(cop, "'some_string'.ends_with?('prefix')")
        expect(cop.offenses.size).to eq(1)
        expect(cop.messages)
          .to eq(['Use `end_with?` instead of `ends_with?`.'])
      end

      it 'is autocorrected' do
        new_source = autocorrect_source(
          cop, "'some_string'.ends_with?('prefix')"
        )
        expect(new_source).to eq "'some_string'.end_with?('prefix')"
      end
    end

    describe '#end_with?' do
      it 'is not registered as an offense' do
        inspect_source(cop, "'some_string'.end_with?('prefix')")
        expect(cop.offenses.size).to eq(0)
      end
    end
  end

  describe 'Array' do
    describe '#append' do
      it 'is registered as an offence' do
        inspect_source(cop, "[1, 'a', 3].append('element')")
        expect(cop.offenses.size).to eq(1)
        expect(cop.messages)
          .to eq(['Use `<<` instead of `append`.'])
      end

      it 'is not autocorrected' do
        source = "[1, 'a', 3].append('element')"
        new_source = autocorrect_source(cop, source)
        expect(new_source).to eq source
      end
    end

    describe '#<<' do
      it 'is not registered as an offense' do
        inspect_source(cop, "[1, 'a', 3] << 'element'")
        expect(cop.offenses.size).to eq(0)
      end
    end

    describe '#prepend' do
      it 'is registered as an offence' do
        inspect_source(cop, "[1, 'a', 3].prepend('element')")
        expect(cop.offenses.size).to eq(1)
        expect(cop.messages)
          .to eq(['Use `unshift` instead of `prepend`.'])
      end

      it 'is autocorrected' do
        new_source = autocorrect_source(
          cop, "[1, 'a', 3].prepend('element')"
        )
        expect(new_source).to eq "[1, 'a', 3].unshift('element')"
      end
    end

    describe '#unshift' do
      it 'is not registered as an offense' do
        inspect_source(cop, "[1, 'a', 3].unshift('element')")
        expect(cop.offenses.size).to eq(0)
      end
    end
  end
end
