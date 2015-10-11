Encoding.default_external = Encoding::UTF_8

module MainApp
  class CitesParser
    RE_REF_SECTION = /^\s*#ref\s*$/
    RE_CITE_DEFINITION = /^\s*#cite\s+(?<identifier>.*?):\s*(?<text>.*)\s*$/
    
    RE_EXTRA_INFO = /(?<options>,\s*.*?)/
    RE_FORMAT = /\|\s*(?<format>.*?)/
    FORMAT_PLACEHOLDER = '%s'
    RE_CITING = /\[cite:\s*(?<identifier>.*?)(?:#{RE_EXTRA_INFO}|#{RE_FORMAT})?\]/
    
    LOCALE_ENCODING = Encoding.find('locale')
    FS_ENCODING = Encoding.find('filesystem')
    
    attr_reader :new_contents
    attr_accessor :input_file
    
    def initialize(file = nil)
      @input_file = file
    end
    
    def run
      contents = File.read(@input_file.encode(FS_ENCODING))
      @new_contents = []
      @chapter = 'a'
      reset_cites
      
      contents.each_line do |line|
        if line.match(RE_REF_SECTION)
          puts_ref
        else
          matches = line.match(RE_CITE_DEFINITION)
          if matches
            @cites_texts[matches['identifier'].strip] = matches['text']
          else
            new_line = line.gsub(RE_CITING) do |substring|
              modify_citing(substring)
            end
            @new_contents << new_line
          end
        end
      end
      
      @new_contents = @new_contents.join
    end
    
    def modify_citing(substring)
      citing = substring.match(RE_CITING)
      identifier = citing['identifier'].strip
      options = citing['options'] && citing['options'].strip
      format = citing['format'] && citing['format'].strip
      
      # no change, format is not respected
      return substring if format && !format.include?(FORMAT_PLACEHOLDER)
      
      format = "%s#{options}" if options
      
      unless @cites_numbers.key?(identifier)
        @cites_numbers[identifier] = @next_number
        @next_number += 1
      end
      ref_number = @cites_numbers[identifier]
      cite_format(ref_number, identifier, format)
    end
    
    def reset_cites
      @cites_numbers = {} # {identifier: output number, ...}
      @cites_texts = {} # {identifier: cite text, ...}
      @next_number = 1
    end
    
    def cite_format(ref_number, identifier, format = nil)
      text = format ? format % ref_number : ref_number
      "[[#{text}]](##{@chapter}-#{identifier})"
    end
    
    def ref_format(identifier)
      num = @cites_numbers[identifier]
      text = @cites_texts[identifier]
      "#{num}. <a name=\"#{@chapter}-#{identifier}\"></a> #{text}\n"
    end
    
    def puts_ref
      assert_cites(@cites_numbers.keys, @cites_texts.keys)
      
      @cites_numbers.each_key do |identifier|
        @new_contents << ref_format(identifier)
      end
      
      @chapter.succ!
      reset_cites
    end
  
    def assert_cites(a, b)
      intersection = a & b
      intersection_size = intersection.size
      equal = intersection_size == a.size && intersection_size == b.size
      unless equal
        missed = (a - intersection) + (b - intersection)
        raise RuntimeError, "Not references correctly: #{missed.join ', '}"
      end
    end
  end
  
  module_function
  
  def help
    puts "USAGE: ruby #{File.basename(__FILENAME__)} input_file.md output_file.md"
  end
  
  def run(input_file, output_file)
    # По неведомой мне причине Ruby принимает от Windows
    # аргументы в кодировке 1251 под видом 866.
    if RUBY_PLATFORM =~ /win32|mingw32/
      fs_encoding = Encoding.find('filesystem')
      input_file = input_file.dup.force_encoding(fs_encoding)
      output_file = output_file.dup.force_encoding(fs_encoding)
    end
    
    parser = CitesParser.new(input_file)
    parser.run
    
    File.open(output_file, 'w') { |f| f << parser.new_contents }
    puts "Finish"
  rescue => e
    STDERR.puts 'Error!', e.message
    STDERR.puts e.backtrace
    exit(1)
  end
end

if ARGV.size == 2
  MainApp.run(ARGV[0], ARGV[1])
else
  MainApp.help
end
