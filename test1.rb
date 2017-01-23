#/usr/bin/env ruby

require "pp"

require "./tui/color.rb"
require "./tui/pixel.rb"
require "./tui/element.rb"
require "./tui/screen.rb"
require "./journal/model.rb"

background = Pixel.new( :s => ":", :c => Color.new(0.2), :b => Color.new(0.15), :l => true )

screen = Screen.new(background)
journal = Journal.new("./journal/test.db")
events = journal.get_month(Date.new(2017,3,1),Date.new(2017,3,31))

x = 5
y = 3

year = 2017
month = 3

(1..31).each do |day|
    date = Date.new(year, month, day)
    y += 1 if (day != 1 && date.monday?)
    box = BoxElement.new( :x => x, :y => y, :w => 100, :h => 1, :p => background )
    text_element = TextElement.new("")
    box.add_child(text_element)
    text = sprintf("%2d", day)
    screen.add_element(box)
    events[year][month][day].each do |event|
        text += "  <1,0,0><b>#{event.title}<t>"
    end
    text_element.text = text
    y += 1
end

screen.draw
