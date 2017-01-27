#!/usr/bin/env ruby

require "io/console"

class Screen

    attr_accessor :elements
    attr_accessor :default_pixel
    attr_accessor :size_x
    attr_accessor :size_y

    def initialize(pixel = Pixel.new)
        @elements = []
        @default_pixel = pixel
        @size_y, @size_x = IO.console.winsize
    end

    def add_element(element)
        @elements << element
    end

    def draw
        data = Hash.new(@default_pixel)

        # terminal resolution
        @size_y, @size_x = IO.console.winsize

        # load elements
        @elements.sort{ |a,b| a.layer <=> b.layer }.each do |element|
            element.draw_on({ :data => data, :size_x => @size_x, :size_y => @size_y })
        end

        # clear screen, go to top/left, reset all styles
        out = "\e[2J\e[H\e[0m"

        last_pixel = Pixel.new


        (1..size_y).each do |y|
            (1..size_x).each do |x|
                pixel = data[[x,y]]
                unless pixel.same_style?(last_pixel)
                    out += "\e[0m"
                    out += "\e[1m"                        if pixel.bold
                    out += "\e[4m"                        if pixel.underline
                    out += "\e[38;5;#{pixel.color}m"      if pixel.color
                    out += "\e[48;5;#{pixel.background}m" if pixel.background
                end
                pixel.symbol = " " unless pixel.symbol
                out += pixel.symbol
                last_pixel = pixel
            end
        end

        out += "\e[0m"

        print out
        $stdout.flush
    end

end
