#!/usr/bin/env ruby

class Element
    attr_accessor :pos_x
    attr_accessor :pos_y
    attr_accessor :layer
    attr_accessor :children

    def add_child(child)
        @children << child
    end
end

class FloatElement < Element

    attr_accessor :float
    attr_accessor :element

    def initialize(element, float)
        @element = element
        @float = float
        @layer = element.layer
    end

    def draw_on(canvas)
        @pos_x = element.pos_x
        @pos_y = element.pos_y

        case @float
            when 1
                element.pos_x = 1
                element.pos_y = 1
            when 2
                element.pos_x = (canvas[:size_x] - element.size_x) / 2 + 1
                element.pos_y = 1
            when 3
                element.pos_x = (canvas[:size_x] - element.size_x) + 1
                element.pos_y = 1
            when 4
                element.pos_x = 1
                element.pos_y = (canvas[:size_y] - element.size_y) / 2 + 1
            when 5
                element.pos_x = (canvas[:size_x] - element.size_x) / 2 + 1
                element.pos_y = (canvas[:size_y] - element.size_y) / 2 + 1
            when 6
                element.pos_x = (canvas[:size_x] - element.size_x) + 1
                element.pos_y = (canvas[:size_y] - element.size_y) / 2 + 1
            when 7
                element.pos_x = 1
                element.pos_y = (canvas[:size_y] - element.size_y) + 1
            when 8
                element.pos_x = (canvas[:size_x] - element.size_x) / 2 + 1
                element.pos_y = (canvas[:size_y] - element.size_y) + 1
            when 9
                element.pos_x = (canvas[:size_x] - element.size_x) + 1
                element.pos_y = (canvas[:size_y] - element.size_y) + 1
        end

        element.draw_on(canvas)

        element.pos_x = @pos_x
        element.pos_y = @pos_y

    end
end

class BoxElement < Element

    attr_accessor :size_x
    attr_accessor :size_y
    attr_accessor :pixel
    attr_accessor :border
    attr_accessor :shadow

    def initialize(values = {})

        @pos_x    = 1
        @pos_y    = 1
        @float    = 0
        @layer    = 1
        @children = []

        @size_x = 1
        @size_y = 1
        @pixel  = Pixel.new
        @border = false
        @shadow = false

        @pos_x  = values[:pos_x]  if values[:pos_x]
        @pos_y  = values[:pos_y]  if values[:pos_y]
        @layer  = values[:layer]  if values[:layer]

        @size_x = values[:size_x] if values[:size_x]
        @size_y = values[:size_y] if values[:size_y]
        @pixel  = values[:pixel]  if values[:pixel]
        @border = values[:border] if values[:border]
        @shadow = values[:shadow] if values[:shadow]

        @pos_x  = values[:x] if values[:x]
        @pos_y  = values[:y] if values[:y]
        @layer  = values[:l] if values[:l]

        @size_x = values[:w] if values[:w]
        @size_y = values[:h] if values[:w]
        @pixel  = values[:p] if values[:p]
        @border = values[:b] if values[:b]
        @shadow = values[:s] if values[:s]
    end

    def draw_on(canvas)

        data = Hash.new(@pixel)

        x1 = @pos_x
        x2 = x1 + @size_x - 1
        y1 = @pos_y
        y2 = y1 + @size_y - 1

        # shadow
        if @shadow
            ((y1+1)..(y2+1)).each do |y|
                ((x1+2)..(x2+2)).each do |x|
                    if x > x2 || y > y2
                        pixel = canvas[:data][[x,y]].deep_clone
                        pixel.color.drop_shadow!
                        pixel.background.drop_shadow!
                        canvas[:data][[x,y]] = pixel
                    end
                end
            end
        end

        # children
        size_x = @size_x
        size_y = @size_y
        if @border
            size_x -= 2
            size_y -= 2
        end

        @children.sort{ |a,b| a.layer <=> b.layer }.each do |child|
            child.draw_on({ :data => data, :size_x => size_x, :size_y => size_y })
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
                canvas[:data][[x,y1]] = canvas[:data][[x,y1]].merge(@pixel)
                canvas[:data][[x,y2]] = canvas[:data][[x,y2]].merge(@pixel)
                canvas[:data][[x,y1]].symbol = "\e(0" + "q" + "\e(B"
                canvas[:data][[x,y2]].symbol = "\e(0" + "q" + "\e(B"
            end
            (y1..y2).each do |y|
                canvas[:data][[x1,y]] = canvas[:data][[x1,y]].merge(@pixel)
                canvas[:data][[x2,y]] = canvas[:data][[x2,y]].merge(@pixel)
                canvas[:data][[x1,y]].symbol = "\e(0" + "x" + "\e(B"
                canvas[:data][[x2,y]].symbol = "\e(0" + "x" + "\e(B"
            end
            canvas[:data][[x1,y1]] = canvas[:data][[x1,y1]].merge(@pixel)
            canvas[:data][[x2,y1]] = canvas[:data][[x2,y1]].merge(@pixel)
            canvas[:data][[x2,y2]] = canvas[:data][[x2,y2]].merge(@pixel)
            canvas[:data][[x1,y2]] = canvas[:data][[x1,y2]].merge(@pixel)
            canvas[:data][[x1,y1]].symbol = "\e(0" + "l" + "\e(B"
            canvas[:data][[x2,y1]].symbol = "\e(0" + "k" + "\e(B"
            canvas[:data][[x2,y2]].symbol = "\e(0" + "j" + "\e(B"
            canvas[:data][[x1,y2]].symbol = "\e(0" + "m" + "\e(B"
        end

    end

end

class TextElement < Element

    attr_accessor :size_x
    attr_accessor :size_y

    def initialize(text, float = 0, values = {})
        @text = text
        @pos_x = 1
        @pos_y = 1
        @float = float
        @layer = 1
        @pos_x = values[:pos_x] if values[:pos_x]
        @pos_y = values[:pos_y] if values[:pos_y]
        @layer = values[:layer] if values[:layer]

        update_data
    end

    def set_text!(text)
        @text = text
        update_data
    end

    def update_data

        @data = []

        pixel = Pixel.new
        y = 1

        @size_x = 0

        @text.split("\n").each do |line|

            tags = {}

            while line.match(/<([^>]+)>/)
                index = Regexp.last_match.offset(0).first
                tag   = Regexp.last_match.captures.first
                line.sub!(/<[^>]+>/, "")
                tags[index] = [] unless tags[index]
                tags[index] << tag
            end

            x = 1

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
                @data << { :x => x, :y => y, :pixel => pixel.deep_clone }
                x += 1
            end
            @size_x = x if @size_x < x
            y += 1
        end
        @size_x -= 1
        @size_y = y -1
    end

    def draw_on(canvas)
        @data.each do |item|
            x = item[:x]
            y = item[:y]
            pixel = item[:pixel]
            canvas[:data][[x+@pos_x-1,y+@pos_y-1]] = canvas[:data][[x+@pos_x-1,y+@pos_y-1]].merge(pixel)
        end
    end

end
