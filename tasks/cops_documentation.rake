# frozen_string_literal: true
require 'yard'
require 'rubocop'

desc 'Generate docs of all cops types'

task generate_cops_documentation: :yard do
  def cop_name_without_type(cop_name)
    cop_name.split('/').last.to_sym
  end

  def cops_of_type(cops, type)
    cops.with_type(type).sort_by!(&:cop_name)
  end

  def cops_body(config, cop, description, examples_objects, pars)
    content = h2(cop.cop_name)
    content << properties(config, cop)
    content << "\n\n"
    content << "#{description}\n"
    content << examples(examples_objects) if examples_objects.count > 0
    content << default_settings(pars)
    content
  end

  def examples(examples_object)
    content = h3('Example')
    content += examples_object.map { |e| code_example(e) }.join
    content
  end

  def properties(config, cop)
    content = "Enabled by default | Supports autocorrection\n".dup
    content << "--- | ---\n"
    default_status = config.cop_enabled?(cop) ? 'Enabled' : 'Disabled'
    supports_autocorrect = cop.new.support_autocorrect? ? 'Yes' : 'No'
    content << "#{default_status} | #{supports_autocorrect}"
    content
  end

  def h2(title)
    content = "\n".dup
    content << "## #{title}\n"
    content << "\n"
    content
  end

  def h3(title)
    content = "\n".dup
    content << "### #{title}\n"
    content << "\n"
    content
  end

  def code_example(ruby_code)
    content = "```ruby\n".dup
    content << ruby_code.text.gsub('@good', '# good')
               .gsub('@bad', '# bad').strip
    content << "\n```\n"
    content
  end

  def default_settings(pars)
    return '' unless pars.keys.count > 0
    content = h3('Important attributes')
    content << "Attribute | Value\n"
    content << "--- | ---\n"
    pars.each do |par|
      content << "#{par.first} | #{format_table_value(par.last)}\n"
    end
    content << "\n"
    content
  end

  def format_table_value(v)
    value = v.is_a?(Array) ? v.join(', ') : v.to_s
    value.gsub("#{Dir.pwd}/", '')
         .gsub('*', '\*')
  end

  def print_cops_of_type(cops, type, config)
    selected_cops = cops_of_type(cops, type)
    content = "# #{type.capitalize}\n".dup
    selected_cops.each do |cop|
      content << print_cop_with_doc(cop, config)
    end
    file_name = "#{Dir.pwd}/manual/cops_#{type}.md"
    File.open(file_name, 'w') do |file|
      puts "* generated #{file_name}"
      file.write(content)
    end
    sleep 1
  end

  def print_cop_with_doc(cop, config)
    t = config.for_cop(cop)
    pars = t.reject { |k| %w(Description Enabled StyleGuide).include? k }
    description = 'No documentation'
    examples_object = []
    YARD::Registry.all.select { |o| !o.docstring.blank? }.map do |o|
      if o.name == cop_name_without_type(cop.cop_name)
        description = o.docstring
        examples_object = o.tags('example')
      end
    end
    cops_body(config, cop, description, examples_object, pars)
  end

  def assert_manual_synchronized
    # Do not print diff and yield whether exit code was zero
    sh('git diff --quiet manual') do |outcome, _|
      return if outcome

      # Output diff before raising error
      sh('git diff manual')

      raise 'The manual directory is out of sync. ' \
        'Run rake generate_cops_documentation and commit the results.'
    end
  end

  cops   = RuboCop::Cop::Cop.all
  config = RuboCop::ConfigLoader.default_configuration

  YARD::Registry.load!
  cops.types.sort!.each { |type| print_cops_of_type(cops, type, config) }

  assert_manual_synchronized if ENV['CI'] == 'true'
end
