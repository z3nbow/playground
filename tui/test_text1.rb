#!/usr/bin/env ruby

require "./color.rb"
require "./pixel.rb"
require "./element.rb"
require "./screen.rb"

default = Pixel.new( :s => ":", :c => Color.new(0.2), :b => Color.new(0.15), :bold => true )
screen = Screen.new(default)

box1 = BoxElement.new( :x => 11, :y => 6, :w => 40, :h => 20, :s => true, :b => true )
box1.default_pixel = Pixel.new( :s => " ", :c => Color.new(1), :b => Color.new(0,0.88888888,0.8) )

screen.add_element(box1)

box2 = BoxElement.new( :x => 15, :y => 21, :w => 20, :h => 15, :s => true, :b => true )
box2.default_pixel = Pixel.new()
screen.add_element(box2)
box2.add_child(TextElement.new("Hallo\nHallo\nHallo\nHallo\nHallo\nHallo"))

text1 = TextElement.new("Hallo", 1, 1)
text2 = TextElement.new("<1></b>Hallo", 1, 2)
box1.add_child(text1)
box1.add_child(text2)

screen.draw
