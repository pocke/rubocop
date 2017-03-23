# frozen_string_literal: true

describe RuboCop::Cop::Style::ClosingParenthesisIndentation do
  subject(:cop) { described_class.new(config) }
  let(:config) do
    RuboCop::Config.new('Style/AlignParameters' => {
                          'EnforcedStyle' => align_parameters_config
                        })
  end
  let(:align_parameters_config) { 'with_first_parameter' }

  context 'for method calls' do
    context 'with line break before 1st parameter' do
      it 'registers an offense for misaligned )' do
        inspect_source(cop, ['some_method(',
                             '  a',
                             '  )'])
        expect(cop.messages)
          .to eq(['Indent `)` the same as the start of the line where `(` is.'])
        expect(cop.highlights).to eq([')'])
      end

      it 'autocorrects misaligned )' do
        corrected = autocorrect_source(cop, ['some_method(',
                                             '  a',
                                             '  )'])
        expect(corrected).to eq ['some_method(',
                                 '  a',
                                 ')'].join("\n")
      end

      it 'accepts a correctly aligned )' do
        inspect_source(cop, ['some_method(',
                             '  a',
                             ')'])
        expect(cop.offenses).to be_empty
      end
    end

    context 'with no line break before 1st parameter' do
      it 'registers an offense for misaligned )' do
        inspect_source(cop, ['some_method(a',
                             ')'])
        expect(cop.messages).to eq(['Align `)` with `(`.'])
        expect(cop.highlights).to eq([')'])
      end

      it 'autocorrects misaligned )' do
        corrected = autocorrect_source(cop, ['some_method(a',
                                             ')'])
        expect(corrected).to eq ['some_method(a',
                                 '           )'].join("\n")
      end

      it 'accepts a correctly aligned )' do
        inspect_source(cop, ['some_method(a',
                             '           )'])
        expect(cop.offenses).to be_empty
      end

      it 'accepts empty ()' do
        inspect_source(cop, 'some_method()')
        expect(cop.offenses).to be_empty
      end

      context 'with fixed indentation of parameters' do
        let(:align_parameters_config) { 'with_fixed_indentation' }

        it 'accepts a correctly indented )' do
          inspect_source(cop, ['some_method(a,',
                               '  x: 1,',
                               '  y: 2',
                               ')',
                               'b =',
                               '  some_method(a,',
                               '  )'])
          expect(cop.offenses).to be_empty
        end

        it 'autocorrects misindented )' do
          corrected = autocorrect_source(cop, ['some_method(a,',
                                               '  x: 1,',
                                               '  y: 2',
                                               '           )',
                                               'b =',
                                               '  some_method(a,',
                                               '             )'])
          expect(corrected).to eq ['some_method(a,',
                                   '  x: 1,',
                                   '  y: 2',
                                   ')',
                                   'b =',
                                   '  some_method(a,',
                                   '  )'].join("\n")
        end
      end
    end
  end

  context 'for method definitions' do
    context 'with line break before 1st parameter' do
      it 'registers an offense for misaligned )' do
        inspect_source(cop, ['def some_method(',
                             '  a',
                             '  )',
                             'end'])
        expect(cop.messages)
          .to eq(['Indent `)` the same as the start of the line where `(` is.'])
        expect(cop.highlights).to eq([')'])
      end

      it 'autocorrects misaligned )' do
        corrected = autocorrect_source(cop, ['def some_method(',
                                             '  a',
                                             '  )',
                                             'end'])
        expect(corrected).to eq ['def some_method(',
                                 '  a',
                                 ')',
                                 'end'].join("\n")
      end

      it 'accepts a correctly aligned )' do
        inspect_source(cop, ['def some_method(',
                             '  a',
                             ')',
                             'end'])
        expect(cop.offenses).to be_empty
      end
    end

    context 'with no line break before 1st parameter' do
      it 'registers an offense for misaligned )' do
        inspect_source(cop, ['def some_method(a',
                             ')',
                             'end'])
        expect(cop.messages).to eq(['Align `)` with `(`.'])
        expect(cop.highlights).to eq([')'])
      end

      it 'autocorrects misaligned )' do
        corrected = autocorrect_source(cop, ['def some_method(a',
                                             ')',
                                             'end'])
        expect(corrected).to eq ['def some_method(a',
                                 '               )',
                                 'end'].join("\n")
      end

      it 'accepts a correctly aligned )' do
        inspect_source(cop, ['def some_method(a',
                             '               )',
                             'end'])
        expect(cop.offenses).to be_empty
      end

      it 'accepts empty ()' do
        inspect_source(cop, ['def some_method()',
                             'end'])
        expect(cop.offenses).to be_empty
      end
    end
  end

  context 'for grouped expressions' do
    context 'with line break before 1st operand' do
      it 'registers an offense for misaligned )' do
        inspect_source(cop, ['w = x * (',
                             '  y + z',
                             '  )'])
        expect(cop.messages)
          .to eq(['Indent `)` the same as the start of the line where `(` is.'])
        expect(cop.highlights).to eq([')'])
      end

      it 'autocorrects misaligned )' do
        corrected = autocorrect_source(cop, ['w = x * (',
                                             '  y + z',
                                             '  )'])
        expect(corrected).to eq ['w = x * (',
                                 '  y + z',
                                 ')'].join("\n")
      end

      it 'accepts a correctly aligned )' do
        inspect_source(cop, ['w = x * (',
                             '  y + z',
                             ')'])
        expect(cop.offenses).to be_empty
      end
    end

    context 'with no line break before 1st operand' do
      it 'registers an offense for misaligned )' do
        inspect_source(cop, ['w = x * (y + z',
                             ')'])
        expect(cop.messages).to eq(['Align `)` with `(`.'])
        expect(cop.highlights).to eq([')'])
      end

      it 'autocorrects misaligned )' do
        corrected = autocorrect_source(cop, ['w = x * (y + z',
                                             '  )'])
        expect(corrected).to eq ['w = x * (y + z',
                                 '        )'].join("\n")
      end

      it 'accepts a correctly aligned )' do
        inspect_source(cop, ['w = x * (y + z',
                             '        )'])
        expect(cop.offenses).to be_empty
      end

      it 'accepts ) that does not begin its line' do
        inspect_source(cop, ['w = x * (y + z +',
                             '        a)'])
        expect(cop.offenses).to be_empty
      end
    end
  end

  it 'accepts begin nodes that are not grouped expressions' do
    inspect_source(cop, ['def a',
                         '  x',
                         '  y',
                         'end'])
    expect(cop.offenses).to be_empty
  end
end
