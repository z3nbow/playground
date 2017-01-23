#!/usr/bin/env ruby

require "io/console"

class Screen

    attr_accessor :elements
    attr_accessor :default_pixel
    attr_accessor :data
    attr_accessor :resolution_x
    attr_accessor :resolution_y

    def initialize(pixel = Pixel.new)
        @elements = []
        @default_pixel = pixel
        @resolution_y, @resolution_x = IO.console.winsize
    end

    def add_element(element)
        @elements << element
    end

    def draw
        @data = Hash.new(@default_pixel)

        # terminal resolution
        @resolution_y, @resolution_x = IO.console.winsize

        # load elements
        @elements.sort{ |a,b| a.layer <=> b.layer }.each do |element|
            element.draw_on(@data)
        end

        out = "\e[2J\e[H\e[0m"

        last_pixel = Pixel.new

        (1..(resolution_y-1)).each do |y|
            (1..resolution_x).each do |x|
                pixel = @data[[x,y]]
                unless pixel.same_style?(last_pixel)
                    out += "\e[0m"
                    out += "\e[1m"                        if pixel.bold
                    out += "\e[4m"                        if pixel.underline
                    out += "\e[38;5;#{pixel.color}m"      if pixel.color
                    out += "\e[48;5;#{pixel.background}m" if pixel.background
                end
                out += pixel.symbol
                last_pixel = pixel
            end
        end

        out += "\e[0m"

        print out
        $stdout.flush
    end

end




