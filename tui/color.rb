#!/usr/bin/env ruby

require "pp"

class Color

    attr_accessor :r
    attr_accessor :g
    attr_accessor :b

    def initialize(r = 1.0, g = nil, b = nil)
        set!(r, g, b)
    end

    def set!(r = 1.0, g = nil, b = nil)
        g, b = r, r if (g.nil? && b.nil?)
        @r, @g, @b = r, g, b
        self
    end

    def set_int!(r = 5, g = nil, b = nil)
        g, b = r, r if (g.nil? && b.nil?)
        self.set!(r/5.0, g/5.0, b/5.0)
    end

    def to_s
        if @r == @g && @g == @b
            ((@r * 23.0).round + 232).to_s
        else
            (16 + (@b * 5.0).round + ((@g * 5.0).round * 6) + ((@r * 5.0).round * 36)).to_s
        end
    end

    def drop_shadow!
        if @r == @g && @g == @b
            @r *= 0.7
            @g *= 0.7
            @b *= 0.7
        else
            @r -= 0.4
            @g -= 0.4
            @b -= 0.4
            @r  = 0 if @r < 0
            @g  = 0 if @g < 0
            @b  = 0 if @b < 0
        end
        self
    end

    def ==(color)
        return false unless color
        @r == color.r && @g == color.g && @b == color.b
    end

    def invert
        Color.new( 1.0 - @r, 1.0 - @g, 1.0 - @b )
    end

end
