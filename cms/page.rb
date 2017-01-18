#!/usr/bin/ruby -w

require "pp"

class Page

    attr_reader     :id
    attr_reader     :content
    attr_accessor   :parent
    attr_accessor   :template

    def initialize file
        @content    = ""
        @variables  = {}
        @parent     = {}

        input = File.read file
        input.scan(/\[\[ ([_a-zA-Z0-9]+) = (\d+|".*?") \]\]/).each do |match|
            @variables[match[0]] = match[1].sub(/^"/, "").sub(/"$/, "")
            input.sub!(/ *\[\[ ([_a-zA-Z0-9]+) = (\d+|".*?") \]\] *\n/, "")
        end

        @id        = @variables["id"]
        @content   = input
        @variables["file"] = file
    end

    def self.is_page? file
        is_page = false
        if not File.zero? file
            is_page = File.open(file).read(32).match(/^\[\[ id = \d+ \]\]/)
        end
        is_page
    end

    def has_key? key
        @variables.has_key? key
    end

    def [] key
        if @variables.has_key?(key)
            @variables[key]
        elsif @parent.is_a?(Page) or @parent.has_key?(key)
            @parent[key]
        else
            ""
        end
    end

end


