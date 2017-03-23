# frozen_string_literal: true

describe RuboCop::PathUtil do
  describe '#relative_path' do
    it 'builds paths relative to PWD by default as a stop-gap' do
      relative = File.join(Dir.pwd, 'relative')
      expect(described_class.relative_path(relative)).to eq('relative')
    end

    it 'supports custom base paths' do
      expect(described_class.relative_path('/foo/bar', '/foo')).to eq('bar')
    end
  end

  describe '#match_path?', :isolated_environment do
    include FileHelper

    before do
      create_file('file', '')
      create_file('dir/file', '')
      create_file('dir/files', '')
      create_file('dir/dir/file', '')
      create_file('dir/sub/file', '')
      create_file('dir/.hidden/file', '')
      create_file('dir/.hidden_file', '')
      $stderr = StringIO.new
    end

    after { $stderr = STDERR }

    it 'does not match dir/** for file in hidden dir' do
      expect(described_class.match_path?('dir/**', 'dir/.hidden/file'))
        .to be_falsey
      expect($stderr.string).to eq('')
    end

    it 'does not match dir/** for hidden file' do
      expect(described_class.match_path?('dir/**', 'dir/.hidden_file'))
        .to be_falsey
      expect($stderr.string).to eq('')
    end

    it 'does not match file in a subdirectory' do
      expect(described_class.match_path?('file', 'dir/files')).to be_falsey
      expect(described_class.match_path?('dir', 'dir/file')).to be_falsey
    end

    it 'matches strings to the full path' do
      expect(described_class.match_path?("#{Dir.pwd}/dir/file",
                                         "#{Dir.pwd}/dir/file")).to be_truthy
      expect(described_class.match_path?(
               "#{Dir.pwd}/dir/file",
               "#{Dir.pwd}/dir/dir/file"
      )).to be_falsey
    end

    it 'matches glob expressions' do
      expect(described_class.match_path?('dir/*', 'dir/file')).to be_truthy
      expect(described_class.match_path?('dir/*/*',
                                         'dir/sub/file')).to be_truthy
      expect(described_class.match_path?('dir/**/*',
                                         'dir/sub/file')).to be_truthy
      expect(described_class.match_path?('dir/**/*', 'dir/file')).to be_truthy
      expect(described_class.match_path?('**/*', 'dir/sub/file')).to be_truthy
      expect(described_class.match_path?('**/file', 'file')).to be_truthy

      expect(described_class.match_path?('sub/*', 'dir/sub/file')).to be_falsey

      expect(described_class.match_path?('**/*',
                                         'dir/.hidden/file')).to be_falsey
      expect(described_class.match_path?('**/*',
                                         'dir/.hidden_file')).to be_falsey
      expect(described_class.match_path?('**/.*/*', 'dir/.hidden/file'))
        .to be_truthy
      expect(described_class.match_path?('**/.*',
                                         'dir/.hidden_file')).to be_truthy
    end

    it 'matches regexps' do
      expect(described_class.match_path?(/^d.*e$/, 'dir/file')).to be_truthy
      expect(described_class.match_path?(/^d.*e$/, 'dir/filez')).to be_falsey
    end
  end
end
