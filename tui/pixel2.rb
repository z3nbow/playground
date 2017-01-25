#!/usr/bin/env ruby

require "./color.rb"

class Pixel

    #attr_accessor :symbol, :color, :background, 

    # symbol        default: nil (transparent)
    # color         default: nil (transparent)
    # background    default: nil (transparent)
    # bold          default: false
    # underline     default: false

    attr_accessor :symbol
    attr_accessor :color
    attr_accessor :background
    attr_accessor :bold
    attr_accessor :underline

    def initialize(values = {})

        # defaults
        @bold      = false
        @underline = false
        
        # set values
        @symbol      = values[:symbol]
        @color       = values[:color]
        @background  = values[:background]
        @bold        = values[:bold]
        @underline   = values[:underline]

        # short names
        @symbol      = values[:s] if values[:s]
        @color       = values[:c] if values[:c]
        @background  = values[:b] if values[:b]
        @bold        = values[:B] if values[:B]
        @underline   = values[:u] if values[:u]

    end

    def same_style?(pixel)
        #return false unless pixel
        @color == pixel.color &&
        @background == pixel.background &&
        @bold == pixel.bold &&
        @underline == pixel.underline
    end

    def deep_clone
        clone = self.clone
        clone.color = @color.clone if @color
        clone.background = @background.clone if @background
        clone
    end

    def merge(pixel)
        # create deep clone of self
        clone = self.deep_clone

        # merge with pixel
        clone.symbol     = pixel.symbol           unless pixel.symbol.nil?
        clone.color      = pixel.color.clone      unless pixel.color.nil?
        clone.background = pixel.background.clone unless pixel.background.nil?
        clone.bold       = pixel.bold             unless pixel.bold?
        clone.underline  = pixel.underline        unless pixel.underline?

        # return merged pixels
        clone
    end

end
