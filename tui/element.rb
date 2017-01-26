#!/usr/bin/env ruby

require "./color.rb"
require "./pixel.rb"

class Element
    attr_accessor :children
    attr_accessor :layer

    def add_child(child)
        @children << child
    end
end

class BoxElement < Element

    attr_accessor :position_x
    attr_accessor :position_y
    attr_accessor :size_x
    attr_accessor :size_y
    attr_accessor :default_pixel
    attr_accessor :border
    attr_accessor :shadow
    attr_accessor :data

    def initialize(values = {})
        @position_x    = 1
        @position_y    = 1
        @size_x        = 1
        @size_y        = 1
        @layer         = 1
        @default_pixel = Pixel.new
        @border        = false
        @shadow        = false
        @data          = {}
        @children      = []

        @position_x    = values[:position_x]    if values[:position_x]
        @position_y    = values[:position_y]    if values[:position_y]
        @size_x        = values[:size_x]        if values[:size_x]
        @size_y        = values[:size_y]        if values[:size_y]
        @layer         = values[:layer]         if values[:layer]
        @default_pixel = values[:default_pixel] if values[:default_pixel]
        @border        = values[:border]        if values[:border]
        @shadow        = values[:shadow]        if values[:shadow]

        @position_x    = values[:x] if values[:x]
        @position_y    = values[:y] if values[:y]
        @size_x        = values[:w] if values[:x]
        @size_y        = values[:h] if values[:y]
        @layer         = values[:l] if values[:l]
        @default_pixel = values[:p] if values[:p]
        @border        = values[:b] if values[:b]
        @shadow        = values[:s] if values[:s]
    end

    def draw_on(canvas)

        data = Hash.new(@default_pixel)

        # help variables
        x1 = @position_x
        x2 = x1 + @size_x - 1
        y1 = @position_y
        y2 = y1 + @size_y - 1

        # shadow
        if @shadow
            ((y1+1)..(y2+1)).each do |y|
                ((x1+2)..(x2+2)).each do |x|
                    #if x > x2 || y > y2
                        pixel = canvas[:data][[x,y]].deep_clone
                        pixel.color.drop_shadow!
                        pixel.background.drop_shadow!
                        canvas[:data][[x,y]] = pixel
                    #end
                end
            end
        end

        # children
        @children.sort{ |a,b| a.layer <=> b.layer }.each do |child|
            child.draw_on({ :data => data, :size_x => @size_x, :size_y => @size_y })
        end

        # draw
        (y1..y2).each do |y|
            (x1..x2).each do |x|
                # inner position
                i_x = x - x1 + 1
                i_y = y - y1 + 1
                if @border
                    i_x -= 1
                    i_y -= 1
                end
                canvas[:data][[x,y]] = canvas[:data][[x,y]].merge(data[[i_x,i_y]])
            end
        end

        # border
        if @border
            (x1..x2).each do |x|
                canvas[:data][[x,y1]] = canvas[:data][[x,y1]].merge(@default_pixel)
                canvas[:data][[x,y2]] = canvas[:data][[x,y2]].merge(@default_pixel)
                canvas[:data][[x,y1]].symbol = "\e(0" + "q" + "\e(B"
                canvas[:data][[x,y2]].symbol = "\e(0" + "q" + "\e(B"
            end
            (y1..y2).each do |y|
                canvas[:data][[x1,y]] = canvas[:data][[x1,y]].merge(@default_pixel)
                canvas[:data][[x2,y]] = canvas[:data][[x2,y]].merge(@default_pixel)
                canvas[:data][[x1,y]].symbol = "\e(0" + "x" + "\e(B"
                canvas[:data][[x2,y]].symbol = "\e(0" + "x" + "\e(B"
            end
            canvas[:data][[x1,y1]] = canvas[:data][[x1,y1]].merge(@default_pixel)
            canvas[:data][[x2,y1]] = canvas[:data][[x2,y1]].merge(@default_pixel)
            canvas[:data][[x2,y2]] = canvas[:data][[x2,y2]].merge(@default_pixel)
            canvas[:data][[x1,y2]] = canvas[:data][[x1,y2]].merge(@default_pixel)
            canvas[:data][[x1,y1]].symbol = "\e(0" + "l" + "\e(B"
            canvas[:data][[x2,y1]].symbol = "\e(0" + "k" + "\e(B"
            canvas[:data][[x2,y2]].symbol = "\e(0" + "j" + "\e(B"
            canvas[:data][[x1,y2]].symbol = "\e(0" + "m" + "\e(B"
        end

    end

end

class TextElement < Element

    attr_accessor :text
    attr_accessor :position_x
    attr_accessor :position_y

    def initialize(text, position_x = 1, position_y = 1, layer = 1)
        @text = text
        @position_x = position_x
        @position_y = position_y
        @layer      = layer
    end

    def draw_on(canvas)

        pixel = Pixel.new
        y = @position_y

        @text.split("\n").each do |line|

            tags = {}

            while line.match(/<([^>]+)>/)
                index = Regexp.last_match.offset(0).first
                tag   = Regexp.last_match.captures.first
                line.sub!(/<[^>]+>/, "")
                tags[index] = [] unless tags[index]
                tags[index] << tag
            end

            x = @position_x

            (0..line.length-1).each do |index|
                if tags[index]
                    tags[index].each do |tag|

                        pixel.bold        = true  if tag == "b"
                        pixel.bold        = false if tag == "/b"
                        pixel.underline   = true  if tag == "u"
                        pixel.underline   = false if tag == "/u"
                        pixel.background  = nil   if tag == "t"

                        if tag.match(/^([01](\.\d+){0,1})$/)
                            grey = Regexp.last_match.captures[0].to_f
                            pixel.color = Color.new(grey)
                        end
                        if tag.match(/^([01](\.\d+){0,1}),([01](\.\d+){0,1}),([01](\.\d+){0,1})$/)
                            r = Regexp.last_match.captures[0].to_f
                            g = Regexp.last_match.captures[2].to_f
                            b = Regexp.last_match.captures[4].to_f
                            pixel.color = Color.new(r, g, b)
                        end
                        if tag.match(/^_([01](\.\d+){0,1})$/)
                            grey = Regexp.last_match.captures[0].to_f
                            pixel.background = Color.new(grey)
                        end
                        if tag.match(/^_([01](\.\d+){0,1}),([01](\.\d+){0,1}),([01](\.\d+){0,1})$/)
                            r = Regexp.last_match.captures[0].to_f
                            g = Regexp.last_match.captures[2].to_f
                            b = Regexp.last_match.captures[4].to_f
                            pixel.background = Color.new(r, g, b)
                        end
                    end
                end
                pixel.symbol = line[index]
                canvas[:data][[x,y]] = canvas[:data][[x,y]].merge(pixel)
                x += 1
            end

            y += 1

        end

    end

end
