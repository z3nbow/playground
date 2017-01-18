#!/usr/bin/env ruby

require "./color.rb"

class Pixel

    attr_accessor :symbol
    attr_accessor :color
    attr_accessor :background
    attr_accessor :bold
    attr_accessor :underline
    attr_accessor :transparent

    def initialize(values = {})
        # set values
        @symbol      = values[:symbol]
        @color       = values[:color]
        @background  = values[:background]
        @bold        = values[:bold]
        @underline   = values[:underline]
        @transparent = values[:transparent]

        # short names
        @symbol      = values[:s] if values[:s]
        @color       = values[:c] if values[:c]
        @background  = values[:b] if values[:b]
        @bold        = values[:l] if values[:l]
        @underline   = values[:u] if values[:u]
        @transparent = values[:t] if values[:t]

        # defaults
        @symbol = " " unless @symbol

        # transparent is default
        @transparent = true if @background == nil && @transparent == nil
    end

    def same_style?(pixel)
        #return false unless pixel
        @color == pixel.color &&
        @background == pixel.background &&
        @bold == pixel.bold &&
        @underline == pixel.underline &&
        @transparent == pixel.transparent
    end

    def deep_clone
        clone = self.clone
        clone.color = @color.clone if @color
        clone.background = @background.clone if @background
        clone
    end

end
