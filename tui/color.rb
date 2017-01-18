#!/usr/bin/env ruby

require "pp"

class Color

    attr_accessor :red
    attr_accessor :green
    attr_accessor :blue

    def initialize(red = 1.0, green = nil, blue = nil)
        set!(red, green, blue)
    end

    def set!(red = 1.0, green = nil, blue = nil)
        if green == nil && blue == nil
            @red = red
            @green = red
            @blue = red
        else
            @red = red
            @green = green
            @blue = blue
        end
        self
    end

    def set_int!(red = 5, green = nil, blue = nil)
        if green == nil && blue == nil
            self.set!(red/5.0)
        else
            self.set!(red/5.0, green/5.0, blue/5.0)
        end
    end

    def to_s
        if @red == @green && @green == @blue
            ((@red * 23.0).round + 232).to_s
        else
            (16 +
             (@blue * 5.0).round +
             ((@green * 5.0).round * 6) +
             ((@red * 5.0).round * 36)).to_s
        end
    end

    def drop_shadow!
        if @red == @green && @green == @blue
            @red   *= 0.7
            @green *= 0.7
            @blue  *= 0.7
        else
            @red   -= 0.4
            @green -= 0.4
            @blue  -= 0.4
            @red    = 0 if @red < 0
            @green  = 0 if @green < 0
            @blue   = 0 if @blue < 0
        end
        self
    end

    def ==(color)
        return false unless color
        @red == color.red && @green == color.green && @blue == color.blue
    end

    def invert
        Color.new( 1.0 - @red, 1.0 - @green, 1.0 - @blue )
    end

end
