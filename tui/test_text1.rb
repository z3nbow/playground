#!/usr/bin/env ruby

require "./color.rb"
require "./pixel.rb"
require "./element.rb"
require "./screen.rb"

default = Pixel.new( :s => ":", :c => Color.new.set_int!(5), :b => Color.new.set_int!(4), :bold => true )
screen = Screen.new(default)

box1 = BoxElement.new( :x => 10, :y => 5, :w => 24, :h => 12, :s => true, :b => true )
box1.pixel = Pixel.new( :s => " ", :c => Color.new(1), :b => Color.new(0,0.8,0.8) )

screen.add_element(FloatElement.new(box1,1))
screen.add_element(FloatElement.new(box1,2))
screen.add_element(FloatElement.new(box1,3))
screen.add_element(FloatElement.new(box1,4))
screen.add_element(FloatElement.new(box1,5))
screen.add_element(FloatElement.new(box1,6))
screen.add_element(FloatElement.new(box1,7))
screen.add_element(FloatElement.new(box1,8))
screen.add_element(FloatElement.new(box1,9))

box2 = BoxElement.new( :x => 15, :y => 21, :w => 20, :h => 15, :s => true, :b => false )
box2.pixel = Pixel.new()
screen.add_element(box2)
box2.add_child(TextElement.new("AA\nBB\n"))

text1 = TextElement.new("Hallo")
text2 = TextElement.new("<1></b>XX<1,0,0>FETT\n<1><b>YO!")
box1.add_child(text1)
box1.add_child(FloatElement.new(text2,1))
box1.add_child(FloatElement.new(text2,2))
box1.add_child(FloatElement.new(text2,3))
box1.add_child(FloatElement.new(text2,4))
box1.add_child(FloatElement.new(text2,5))
box1.add_child(FloatElement.new(text2,6))
box1.add_child(FloatElement.new(text2,7))
box1.add_child(FloatElement.new(text2,8))
box1.add_child(FloatElement.new(text2,9))

screen.draw
