module MainApp
  class CitesParser
    RE_REF_SECTION = /^\s*#ref\s*$/
    RE_CITE_DEFINITION = /^\s*#cite\s+(?<identifier>.*?):\s*(?<text>.*)\s*$/
    RE_CITING = /\[cite:\s*(.*?)\]/
    
    attr_reader :new_contents
    attr_accessor :input_file
    
    def initialize(file = nil)
      @input_file = file
    end
    
    def run
      contents = File.read(input_file)
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
              identifier = substring.match(RE_CITING)[1]
              identifier.strip!
              unless @cites_numbers.key?(identifier)
                @cites_numbers[identifier] = @next_number
                @next_number += 1
              end
              ref_number = @cites_numbers[identifier]
              cite_format(ref_number, identifier)
            end
            @new_contents << new_line
          end
        end
      end
      
      @new_contents = @new_contents.join
    end
    
    def reset_cites
      @cites_numbers = {} # {identifier: output number, ...}
      @cites_texts = {} # {identifier: cite text, ...}
      @next_number = 1
    end
    
    def cite_format(ref_number, identifier)
      "[[#{ref_number}]](##{@chapter}-#{identifier})"
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
      intersection = a && b
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
    parser = CitesParser.new(input_file)
    parser.run
    
    File.open(output_file, 'w') { |f| f << parser.new_contents }
    puts "Finish"
  rescue => e
    STDERR.puts 'Error!', e.message
    exit(1)
  end
end

if ARGV.size == 2
  MainApp.run(ARGV[0], ARGV[1])
else
  MainApp.help
end
