#!/usr/bin/env ruby

require "pp"
require "io/console"

require "./tui/color.rb"
require "./tui/pixel.rb"
require "./tui/element.rb"
require "./tui/screen.rb"
require "./journal/model.rb"

MONTHS   = { 1 => "Januar", 2 => "Februar", 3 => "März" }
WEEKDAYS = { 0 => "Sonntag", 1 => "Montag", 2 => "Dienstag", 3 => "Mittwoch", 4 => "Donnerstag", 5 => "Freitag", 6 => "Samstag" }
STYLE    = { }
            

TEXT_COLORS = { :header => "<b><0.2,0.8,0.2>",
                :day    => "<b><1>",
                :day_we => "<b><0.2,0.8,0.2>",
                :text   => "<1>" }

$background = Pixel.new( :s => ":", :c => Color.new.set_int!(3), :b => Color.new.set_int!(2), :bold => true )
$screen     = Screen.new($background)

$journal    = Journal.new("./journal/test.db")

def draw_month(year, month)

    # last day of this month: 28, 29, 30 or 31
    last_day = Date.new(year, month, -1).day

    # get all events
    events = $journal.get_events(Date.new(year, month, 1), Date.new(year, month, last_day))

    # clear screen
    $screen.elements = []

    # add default element
    # header
    # footer
    # etc.

    # container box
    b_container = BoxElement.new( :x => 0, :y => 0, :w => 164, :h => 50, :s => true, :p => Pixel.new )
    $screen.add_element(FloatElement.new(b_container, 5))

    # box for events
    b_events = BoxElement.new( :w => 82, :h => 40, :s => true, :b => true, :p => Pixel.new( :c => Color.new(0.2,0.2,0), :b => Color.new.set_int!(5), :s => " ", :bold => true ))
    b_container.add_child(b_events)

    # box for tasks
    b_tasks = BoxElement.new( :x => 83, :w => 82, :h => 40, :s => true, :b => true, :p => Pixel.new( :c => Color.new(0.2,0.2,0), :b => Color.new.set_int!(5), :s => " ", :bold => true ))
    b_container.add_child(b_tasks)
    
    b_1 = BoxElement.new( :y => 41, :w => 82, :h => 10, :s => true, :b => true, :p => Pixel.new( :c => Color.new(0.2,0.2,0), :b => Color.new.set_int!(5), :s => " ", :bold => true ))
    b_2 = BoxElement.new( :x => 83, :y => 41, :w => 82, :h => 10, :s => true, :b => true, :p => Pixel.new( :c => Color.new(0.2,0.2,0), :b => Color.new.set_int!(5), :s => " ", :bold => true ))
    b_container.add_child(b_1)
    b_container.add_child(b_2)

    
    # header in events
    b_events.add_child(TextElement.new("#{TEXT_COLORS[:header]} #{MONTHS[month].upcase} #{year}", 1, 1))
    #b_events.add_child(TextElement.new("#{TEXT_COLORS[:header]} " + "=" * (MONTH_NAMES[month].length + 5), 1, 3))

    # hash for all events and text elements
    events_hash = {}

    # current row in b_events
    #y = 5
    y = 3

    $screen.draw

    # loop over all days in current month
    (1..last_day).each do |day|

        # date element of current day
        date = Date.new(year, month, day)

        # leave one row empty if current day is a monday and not the beginning of the month
        y += 1 if date.monday? && day != 1

        color = TEXT_COLORS[:day]
        color = TEXT_COLORS[:day_we] if date.saturday? || date.sunday?

        # add day number to current row
        b_events.add_child(TextElement.new(sprintf("#{color}%2d", day), 1, y))

        # add weekday name to current row
        b_events.add_child(TextElement.new("#{color}" + WEEKDAYS[date.wday].capitalize[0..1], 5, y))

        # Create empty array in events_hash for current day, will be filled by next loop
        events_hash[day] = []

        # set cursor position in current row
        x = 9

        # loop over all events of current day
        events[year][month][day].each_with_index do |event, index|

            # add seperator if not first element of current day
            if index > 0
                b_events.add_child(TextElement.new("<0.2,0.8,0.2><b>|", x, y))
                x += 3
            end

            # add event
            events_hash[day][index] = {}
            events_hash[day][index][:event] = event
            events_hash[day][index][:text_element] = TextElement.new("<1>#{TEXT_COLORS[:text]}#{event.title}", x, y)
            b_events.add_child(events_hash[day][index][:text_element])

            # move cursor
            x += events_hash[day][index][:text_element].size_x + 2

        # end of loop over all events of current day
        end

        # add invisible text element for adding events
        text_element = TextElement.new("", x, y)
        b_events.add_child(text_element)
        events_hash[day] << { :event => nil, :text_element => text_element }

        # next row
        y += 1

    # end of loop over all days in current month
    end

    $screen.draw

    events_hash

end

year = 2017
month = 1

$events = draw_month(year, month)

$m_day = 1
$m_idx = 1



run = true
while run
    key = IO.console.getch
    run = false if key == "q"
    if key == "1" && month > 1
        month -= 1
        $events = draw_month(year, month)
        $m_day = 1
        $m_idx = 1
        #redraw_month()
    elsif key == "2" && month < 12
        month += 1
        $events = draw_month(year, month)
        $m_day = 1
        $m_idx = 1
        #redraw_month()
    end
end
