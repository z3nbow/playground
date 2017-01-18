#!/usr/bin/env ruby

require "./color.rb"
require "./pixel.rb"
require "./element.rb"
require "./screen.rb"

size_x    = 6
size_y    = 2
padding_x = 4
padding_y = padding_x / 2

screen = Screen.new(Pixel.new( :s => ":", :c => Color.new(0.2), :b => Color.new(0.15), :l => true ))

(0..5).each do |b|
    (0..5).each do |g|
        (0..5).each do |r|
            if b < 3
                s_x = b * 6 * (size_x + padding_x)
                s_y = 0
            else
                s_x = (b - 3) * 6 * (size_x + padding_x)
                s_y = 6 * (size_y + padding_y)
            end
            x = r * (size_x + padding_x) + padding_x + s_x + 1
            y = g * (size_y + padding_y) + padding_y + s_y + 1
            box = BoxElement.new( :s => true, :x => x, :y => y, :w => size_x, :h => size_y, :p => Pixel.new( :b => Color.new.set_int!(b, g, r) ))
            if r + g + b <= 4
                col = Color.new(1)
            else
                col = Color.new(0)
            end
            box.data[[1,1]] = Pixel.new( :s => b.to_s, :c => col )
            box.data[[2,1]] = Pixel.new( :s => g.to_s, :c => col )
            box.data[[3,1]] = Pixel.new( :s => r.to_s, :c => col )
            screen.add_element(box)
        end
    end

end




screen.draw
