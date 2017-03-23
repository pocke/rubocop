# frozen_string_literal: true

describe RuboCop::Cop::Style::IndentArray do
  subject(:cop) { described_class.new(config) }
  let(:config) do
    supported_styles = {
      'SupportedStyles' => %w(special_inside_parentheses consistent
                              align_brackets)
    }
    RuboCop::Config.new('Style/IndentArray' =>
                        cop_config.merge(supported_styles).merge(
                          'IndentationWidth' => cop_indent
                        ),
                        'Style/IndentationWidth' => { 'Width' => 2 })
  end
  let(:cop_config) { { 'EnforcedStyle' => 'special_inside_parentheses' } }
  let(:cop_indent) { nil } # use indent from Style/IndentationWidth

  context 'when array is operand' do
    it 'accepts correctly indented first element' do
      inspect_source(cop,
                     ['a << [',
                      '  1',
                      ']'])
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for incorrectly indented first element' do
      inspect_source(cop,
                     ['a << [',
                      ' 1',
                      ']'])
      expect(cop.highlights).to eq(['1'])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'auto-corrects incorrectly indented first element' do
      corrected = autocorrect_source(cop, ['a << [',
                                           ' 1',
                                           ']'])
      expect(corrected).to eq ['a << [',
                               '  1',
                               ']'].join("\n")
    end

    it 'registers an offense for incorrectly indented ]' do
      inspect_source(cop,
                     ['a << [',
                      '  ]'])
      expect(cop.highlights).to eq([']'])
      expect(cop.messages)
        .to eq(['Indent the right bracket the same as the start of the line ' \
                'where the left bracket is.'])
      expect(cop.config_to_allow_offenses).to be_empty
    end

    context 'when indentation width is overridden for this cop' do
      let(:cop_indent) { 4 }

      it 'accepts correctly indented first element' do
        inspect_source(cop,
                       ['a << [',
                        '    1',
                        ']'])
        expect(cop.offenses).to be_empty
      end

      it 'registers an offense for incorrectly indented first element' do
        inspect_source(cop,
                       ['a << [',
                        '  1',
                        ']'])
        expect(cop.highlights).to eq(['1'])
        expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
      end
    end
  end

  context 'when array is argument to setter' do
    it 'accepts correctly indented first element' do
      inspect_source(cop,
                     ['   config.rack_cache = [',
                      '     "rails:/",',
                      '     "rails:/",',
                      '     false',
                      '   ]'])
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for incorrectly indented first element' do
      inspect_source(cop,
                     ['   config.rack_cache = [',
                      '   "rails:/",',
                      '   "rails:/",',
                      '   false',
                      '   ]'])
      expect(cop.highlights).to eq(['"rails:/"'])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end
  end

  context 'when array is right hand side in assignment' do
    it 'registers an offense for incorrectly indented first element' do
      inspect_source(cop, ['a = [',
                           '    1,',
                           '  2,',
                           ' 3',
                           ']'])
      expect(cop.messages)
        .to eq(['Use 2 spaces for indentation in an array, relative to the ' \
                'start of the line where the left square bracket is.'])
      expect(cop.highlights).to eq(['1'])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'auto-corrects incorrectly indented first element' do
      corrected = autocorrect_source(cop, ['a = [',
                                           '    1,',
                                           '  2,',
                                           ' 3',
                                           ']'])
      expect(corrected).to eq ['a = [',
                               '  1,',
                               '  2,',
                               ' 3',
                               ']'].join("\n")
    end

    it 'accepts correctly indented first element' do
      inspect_source(cop,
                     ['a = [',
                      '  1',
                      ']'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts several elements per line' do
      inspect_source(cop,
                     ['a = [',
                      '  1, 2',
                      ']'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts a first element on the same line as the left bracket' do
      inspect_source(cop,
                     ['a = [1,',
                      '     2]'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts single line array' do
      inspect_source(cop,
                     'a = [1, 2]')
      expect(cop.offenses).to be_empty
    end

    it 'accepts an empty array' do
      inspect_source(cop,
                     'a = []')
      expect(cop.offenses).to be_empty
    end

    it 'accepts multi-assignments with brackets' do
      inspect_source(cop,
                     'a, b = [b, a]')
      expect(cop.offenses).to be_empty
    end

    it 'accepts multi-assignments with no brackets' do
      inspect_source(cop,
                     'a, b = b, a')
      expect(cop.offenses).to be_empty
    end
  end

  context 'when array is method argument' do
    context 'and arguments are surrounded by parentheses' do
      context 'and EnforcedStyle is special_inside_parentheses' do
        it 'accepts special indentation for first argument' do
          inspect_source(cop,
                         # Only the function calls are affected by
                         # EnforcedStyle setting. Other indentation shall be
                         # the same regardless of EnforcedStyle.
                         ['h = [',
                          '  1',
                          ']',
                          'func([',
                          '       1',
                          '     ])',
                          'func(x, [',
                          '       1',
                          '     ])',
                          'h = [1',
                          ']',
                          'func([1',
                          '     ])',
                          'func(x, [1',
                          '     ])'])
          expect(cop.offenses).to be_empty
        end

        it "registers an offense for 'consistent' indentation" do
          inspect_source(cop,
                         ['func([',
                          '  1',
                          '])'])
          expect(cop.messages)
            .to eq(['Use 2 spaces for indentation in an array, relative to ' \
                    'the first position after the preceding left parenthesis.',
                    'Indent the right bracket the same as the first position ' \
                    'after the preceding left parenthesis.'])
          expect(cop.config_to_allow_offenses)
            .to eq('EnforcedStyle' => 'consistent')
        end

        it "registers an offense for 'align_brackets' indentation" do
          inspect_source(cop,
                         ['var = [',
                          '        1',
                          '      ]'])
          # since there are no parens, warning message is for 'consistent' style
          expect(cop.messages)
            .to eq(['Use 2 spaces for indentation in an array, relative to ' \
                    'the start of the line where the left square bracket is.',
                    'Indent the right bracket the same as the start of the ' \
                    'line where the left bracket is.'])
          expect(cop.config_to_allow_offenses)
            .to eq('EnforcedStyle' => 'align_brackets')
        end

        it 'auto-corrects incorrectly indented first element' do
          corrected = autocorrect_source(cop, ['func([',
                                               '  1',
                                               '])'])
          expect(corrected).to eq ['func([',
                                   '       1',
                                   '     ])'].join("\n")
        end

        it 'accepts special indentation for second argument' do
          inspect_source(cop,
                         ['body.should have_tag("input", [',
                          '                       :name])'])
          expect(cop.offenses).to be_empty
        end

        it 'accepts normal indentation for array within array' do
          inspect_source(cop,
                         ['puts(',
                          '  [',
                          '    [1, 2]',
                          '  ]',
                          ')'])
          expect(cop.offenses).to be_empty
        end
      end

      context 'and EnforcedStyle is consistent' do
        let(:cop_config) { { 'EnforcedStyle' => 'consistent' } }

        it 'accepts normal indentation for first argument' do
          inspect_source(cop,
                         # Only the function calls are affected by
                         # EnforcedStyle setting. Other indentation shall be
                         # the same regardless of EnforcedStyle.
                         ['h = [',
                          '  1',
                          ']',
                          'func([',
                          '  1',
                          '])',
                          'func(x, [',
                          '  1',
                          '])',
                          'h = [1',
                          ']',
                          'func([1',
                          '])',
                          'func(x, [1',
                          '])'])
          expect(cop.offenses).to be_empty
        end

        it 'registers an offense for incorrect indentation' do
          inspect_source(cop,
                         ['func([',
                          '       1',
                          '     ])'])
          expect(cop.messages)
            .to eq(['Use 2 spaces for indentation in an array, relative to ' \
                    'the start of the line where the left square bracket is.',

                    'Indent the right bracket the same as the start of the ' \
                    'line where the left bracket is.'])
          expect(cop.config_to_allow_offenses)
            .to eq('EnforcedStyle' => 'special_inside_parentheses')
        end

        it 'accepts normal indentation for second argument' do
          inspect_source(cop,
                         ['body.should have_tag("input", [',
                          '  :name])'])
          expect(cop.offenses).to be_empty
        end
      end
    end

    context 'and argument are not surrounded by parentheses' do
      it 'accepts bracketless array' do
        inspect_source(cop,
                       'func 1, 2')
        expect(cop.offenses).to be_empty
      end

      it 'accepts single line array with brackets' do
        inspect_source(cop,
                       'func x, [1, 2]')
        expect(cop.offenses).to be_empty
      end

      it 'accepts a correctly indented multi-line array with brackets' do
        inspect_source(cop,
                       ['func x, [',
                        '  1, 2]'])
        expect(cop.offenses).to be_empty
      end

      it 'registers an offense for incorrectly indented multi-line array ' \
         'with brackets' do
        inspect_source(cop,
                       ['func x, [',
                        '       1, 2]'])
        expect(cop.messages)
          .to eq(['Use 2 spaces for indentation in an array, relative to the ' \
                  'start of the line where the left square bracket is.'])
        expect(cop.highlights).to eq(['1'])
        expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
      end
    end
  end

  context 'when EnforcedStyle is align_brackets' do
    let(:cop_config) { { 'EnforcedStyle' => 'align_brackets' } }

    it 'accepts correctly indented first element' do
      inspect_source(cop,
                     ['a = [',
                      '      1',
                      '    ]'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts several elements per line' do
      inspect_source(cop,
                     ['a = [',
                      '      1, 2',
                      '    ]'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts a first element on the same line as the left bracket' do
      inspect_source(cop,
                     ['a = [1,',
                      '     2]'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts single line array' do
      inspect_source(cop,
                     'a = [1, 2]')
      expect(cop.offenses).to be_empty
    end

    it 'accepts an empty array' do
      inspect_source(cop,
                     'a = []')
      expect(cop.offenses).to be_empty
    end

    it 'accepts multi-assignments with brackets' do
      inspect_source(cop,
                     'a, b = [b, a]')
      expect(cop.offenses).to be_empty
    end

    it 'accepts multi-assignments with no brackets' do
      inspect_source(cop,
                     'a, b = b, a')
      expect(cop.offenses).to be_empty
    end

    context "when 'consistent' style is used" do
      it 'registers an offense for incorrect indentation' do
        inspect_source(cop,
                       ['func([',
                        '  1',
                        '])'])
        expect(cop.messages)
          .to eq(['Use 2 spaces for indentation in an array, relative to the' \
                  ' position of the opening bracket.',
                  'Indent the right bracket the same as the left bracket.'])
        expect(cop.config_to_allow_offenses)
          .to eq('EnforcedStyle' => 'consistent')
      end

      it 'auto-corrects incorrectly indented first element' do
        corrected = autocorrect_source(cop, ['var = [',
                                             '  1',
                                             ']'])
        expect(corrected).to eq ['var = [',
                                 '        1',
                                 '      ]'].join("\n")
      end
    end

    context "when 'special_inside_parentheses' style is used" do
      it 'registers an offense for incorrect indentation' do
        inspect_source(cop,
                       ['var = [',
                        '  1',
                        ']',
                        'func([',
                        '       1',
                        '     ])'])
        expect(cop.messages)
          .to eq(['Use 2 spaces for indentation in an array, relative to the' \
                  ' position of the opening bracket.',
                  'Indent the right bracket the same as the left bracket.'])
        expect(cop.config_to_allow_offenses)
          .to eq('EnforcedStyle' => 'special_inside_parentheses')
      end
    end

    it 'registers an offense for incorrectly indented ]' do
      inspect_source(cop,
                     ['a << [',
                      '  ]'])
      expect(cop.highlights).to eq([']'])
      expect(cop.messages)
        .to eq(['Indent the right bracket the same as the left bracket.'])
      expect(cop.config_to_allow_offenses).to be_empty
    end

    context 'when indentation width is overridden for this cop' do
      let(:cop_indent) { 4 }

      it 'accepts correctly indented first element' do
        inspect_source(cop,
                       ['a = [',
                        '        1',
                        '    ]'])
        expect(cop.offenses).to be_empty
      end

      it 'autocorrects indentation which does not match IndentationWidth' do
        new_source = autocorrect_source(cop, ['a = [',
                                              '      1',
                                              '    ]'])
        expect(new_source).to eq(['a = [',
                                  '        1',
                                  '    ]'].join("\n"))
      end
    end
  end
end
