#/usr/bin/env ruby

require "pp"
require "io/console"

require "./tui/color.rb"
require "./tui/pixel.rb"
require "./tui/element.rb"
require "./tui/screen.rb"
require "./journal/model.rb"

MONTH_NAMES = ["", "Januar", "Februar", "März", "April", "Mai", "Juni",
               "Juli", "August", "September", "Oktober", "November", "Dezember"]
WEEKDAY_NAMES = ["sonntag", "montag", "dienstag", "mittwoch", "donnerstag", "freitag", "samstag"]

$background = Pixel.new( :s => ":", :c => Color.new(0.2), :b => Color.new(0.15), :l => true )
$screen     = Screen.new($background)
$journal    = Journal.new("./journal/test.db")

def draw_month(year, month)
    last_day = Date.new(year, month, -1).day
    events = $journal.get_month(Date.new(year, month, 1), Date.new(year, month, last_day))
    $screen.elements = []
    x = 5
    y = 3
    $screen.add_element(TextElement.new("<b><0.2,0.6,1>" + MONTH_NAMES[month].upcase + " " + year.to_s, x+1, y))
    y += 2
    $screen.add_element(TextElement.new("<b><0.2,0.6,1>" + ":" * MONTH_NAMES[month].length + ":::::", x+1, y))
    y += 2
    (1..last_day).each do |day|
        date = Date.new(year, month, day)
        y += 1 if day != 1 && Date.new(year, month, day).monday?
        if date.saturday? || date.sunday?
            text = "<b>" + "<0.2>:" * (2 - day.to_s.length) + "<1,0.2,0.2>" + day.to_s
            text += "<0.2>::<1,0.2,0.2></b>" + WEEKDAY_NAMES[Date.new(year, month, day).wday].capitalize[0..1].to_s
        else
            text = "<b>" + "<0.2>:" * (2 - day.to_s.length) + "<0.2,0.6,1>" + day.to_s
            text += "<0.2>::<0.2,0.6,1></b>" + WEEKDAY_NAMES[Date.new(year, month, day).wday].capitalize[0..1].to_s
        end
        element = TextElement.new(text, x, y)
        $screen.add_element(element)
        events[year][month][day].each_with_index do |event, index|
            element.text += "<0.2>::" if index == 0
            element.text += "<0.2>::<0.2,0.6,1>:<0.2>::" if index > 0
            if event.id % 10 == 0
                element.text += "<1><b><_0,0.4,0.8>#{event.title}<t>"
            else
                element.text += "<1></b>#{event.title}<b>"
            end
            event.data[:text_element] = element
        end
        y += 1
    end
    $screen.draw
end

year = 2017
month = 1
draw_month(year, month)

run = true
while run
    key = IO.console.getch
    run = false if key == "q"
    if key == "1" && month > 1
        month -= 1
        draw_month(year, month)
    elsif key == "2" && month < 12
        month += 1
        draw_month(year, month)
    end
end
