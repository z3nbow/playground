#!/usr/bin/ruby -w

class Chunk
    attr_reader :name
    attr_reader :content

    def initialize file
        input = File.read(file)
        input.scan(/^\[\[ name = "(.*?)" \]\]/).each do |match|
            @name = match[0]
            input.sub!(/^ *\[\[ name = "#{@name}" \]\] *\n/, "")
        end
        @content = input
    end

    def self.is_chunk? file
        if File.zero?(file)
            false
        else
            File.open(file).read(128).match(/^\[\[ name = \".*?\" \]\]/)
        end
    end
end
