# frozen_string_literal: true

require 'rubocop'

desc 'Generate a new cop template'
task :new_cop, [:cop] do |_task, args|
  def to_snake(str)
    str
      .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
      .gsub(/([a-z\d])([A-Z])/, '\1_\2')
      .tr('-', '_')
      .downcase
  end

  cop_name = args[:cop] # Department/Name
  raise ArgumentError, 'One argument is required' unless cop_name

  badge = RuboCop::Cop::Badge.parse(cop_name)

  unless badge.qualified?
    raise ArgumentError, 'Specify a cop name with Department/Name style'
  end

  cop_code = <<-END.strip_indent
    # frozen_string_literal: true

    # TODO: when finished, run `rake generate_cops_documentation` to update the docs
    module RuboCop
      module Cop
        module #{badge.department}
          # TODO: Write cop description and example of bad / good code.
          #
          # @example
          #   # bad
          #   bad_method()
          #
          #   # bad
          #   bad_method(args)
          #
          #   # good
          #   good_method()
          #
          #   # good
          #   good_method(args)
          class #{badge.cop_name} < Cop
            # TODO: Implement the cop into here.
            #
            # In many cases, you can use a node matcher for matching node pattern.
            # See. https://github.com/bbatsov/rubocop/blob/master/lib/rubocop/node_pattern.rb
            #
            # For example
            MSG = 'Message of #{badge.cop_name}'.freeze

            def_node_matcher :bad_method?, <<-PATTERN
              (send nil :bad_method ...)
            PATTERN

            def on_send(node)
              return unless bad_method?(node)
              add_offense(node, :expression)
            end
          end
        end
      end
    end
  END

  cop_path = "lib/rubocop/cop/#{to_snake(badge.to_s)}.rb"
  raise "#{cop_path} already exists!" if File.exist?(cop_path)
  File.write(cop_path, cop_code)

  spec_code = <<-END.strip_indent
    # frozen_string_literal: true

    describe RuboCop::Cop::#{badge.department}::#{badge.cop_name} do
      let(:config) { RuboCop::Config.new }
      subject(:cop) { described_class.new(config) }

      # TODO: Write test code
      #
      # For example
      it 'registers an offense for offending code' do
        inspect_source(cop, 'bad_method')
        expect(cop.offenses.size).to eq(1)
        expect(cop.messages)
          .to eq(['Message of #{badge.cop_name}'])
      end

      it 'accepts' do
        inspect_source(cop, 'good_method')
        expect(cop.offenses).to be_empty
      end
    end
  END

  spec_path = "spec/rubocop/cop/#{to_snake(cop_name)}_spec.rb"
  raise "#{spec_path} already exists!" if File.exist?(spec_path)
  File.write(spec_path, spec_code)

  puts <<-END.strip_indent
    created
    - #{cop_path}
    - #{spec_path}

    Do 4 steps
    - Add an entry to `New feature` section in CHANGELOG.md
      - e.g. Add new `#{badge.cop_name}` cop. ([@your_id][])
    - Add `require '#{cop_path.gsub(/\.rb$/, '').gsub(%r{^lib/}, '')}'` into lib/rubocop.rb
    - Add an entry into config/enabled.yml or config/disabled.yml
    - Implement a new cop to the generated file!
  END
end
