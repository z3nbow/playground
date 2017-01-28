#!/usr/bin/env ruby

require "pp"
require "io/console"

require "./tui/color.rb"
require "./tui/pixel.rb"
require "./tui/element.rb"
require "./tui/screen.rb"
require "./journal/model.rb"

MONTH_NAMES = ["", "Januar", "Februar", "März", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober", "November", "Dezember"]
WEEKDAY_NAMES = ["sonntag", "montag", "dienstag", "mittwoch", "donnerstag", "freitag", "samstag"]
TEXT_COLORS = { :header => "<0.2,0.6,1>",
                :day    => "<0.2,0.6,1>",
                :day_we => "<1,0.6,0.2>",
                :text   => "<0.9>" }

$background = Pixel.new( :s => ":", :c => Color.new.set_int!(5), :b => Color.new.set_int!(4), :bold => true )
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

    # add box for the calendar
    events_box = BoxElement.new(:x => 4, :y => 2)

    # add box to screen
    $screen.add_element(FloatElement.new(events_box, 1))

    # header in row 1 and 3
    events_box.add_child(TextElement.new("<t><b>#{TEXT_COLORS[:header]} #{MONTH_NAMES[month].upcase} #{year}", 1, 1))
    #events_box.add_child(TextElement.new("<t><b>#{TEXT_COLORS[:header]} " + "=" * (MONTH_NAMES[month].length + 5), 1, 3))

    # hash for all events and text elements
    events_hash = {}

    # current row in events_box
    #y = 5
    y = 3

    # loop over all days in current month
    (1..last_day).each do |day|

        # date element of current day
        date = Date.new(year, month, day)

        # leave one row empty if current day is a monday and not the beginning of the month
        y += 1 if date.monday? && day != 1

        color = TEXT_COLORS[:day]
        color = TEXT_COLORS[:day_we] if date.saturday? || date.sunday?

        # add day number to current row
        events_box.add_child(TextElement.new(sprintf("#{color}%2d", day), 1, y))

        # add weekday name to current row
        events_box.add_child(TextElement.new("#{color}" + WEEKDAY_NAMES[date.wday].capitalize[0..1], 5, y))

        # Create empty array in events_hash for current day, will be filled by next loop
        events_hash[day] = []

        # set cursor position in current row
        x = 9

        # loop over all events of current day
        events[year][month][day].each_with_index do |event, index|

            # add seperator if not first element of current day
            if index > 0
                events_box.add_child(TextElement.new("<0.5><b>|", x, y))
                x += 3
            end

            # add event
            events_hash[day][index] = {}
            events_hash[day][index][:event] = event
            events_hash[day][index][:text_element] = TextElement.new("<1>#{TEXT_COLORS[:text]}#{event.title}", x, y)
            events_box.add_child(events_hash[day][index][:text_element])

            # move cursor
            x += events_hash[day][index][:text_element].size_x + 2

        # end of loop over all events of current day
        end

        # add invisible text element for adding events
        text_element = TextElement.new("", x, y)
        events_box.add_child(text_element)
        events_hash[day] << { :event => nil, :text_element => text_element }

        # next row
        y += 1

    # end of loop over all days in current month
    end

    events_box.size_x = 100
    events_box.size_y = y - 1

    # for testing with border
    #events_box.size_x += 2
    #events_box.size_y += 2
    #events_box.border = true
    #events_box.pixel  = Pixel.new( :s => " ", :c => Color.new(1), :b => Color.new(0.3))

    $screen.draw

    events_hash

end

def redraw_month(direction = false)

    event = $events[$m_day][$m_idx - 1]

    if direction

        if event[:event].nil?
            event[:text_element].set_text!("")
        else
            event[:text_element].set_text!("<1>#{TEXT_COLORS[:text]}#{event[:event].title}")
        end

        case direction
            when "right"
                $m_idx += 1 if $m_idx < $events[$m_day].length
            when "left"
                $m_idx -= 1 if $m_idx > 1
            when "up"
                if $m_day > 1
                    $m_day -= 1
                    $m_idx = 1
                end
            when "down"
                $m_day += 1
                $m_idx = 1
        end
    end

    event = $events[$m_day][$m_idx - 1]
    if event[:event].nil?
        event[:text_element].set_text!("<b><0.5>|  <_0.2,0.6,1><1></t>Add event")
    else
        event[:text_element].set_text!("<b><1><_0.2,0.6,1>#{event[:event].title}")
    end
    $screen.draw

    #events_hash[day][index][:text_element] = TextElement.new("<1>#{TEXT_COLORS[:text]}#{event.title}", x, y)
end

year = 2017
month = 1

$events = draw_month(year, month)

$m_day = 1
$m_idx = 1
redraw_month()



run = true
while run
    key = IO.console.getch
    run = false if key == "q"
    if key == "1" && month > 1
        month -= 1
        $events = draw_month(year, month)
        $m_day = 1
        $m_idx = 1
        redraw_month()
    elsif key == "2" && month < 12
        month += 1
        $events = draw_month(year, month)
        $m_day = 1
        $m_idx = 1
        redraw_month()
    elsif key == "w"
        box = BoxElement.new( :w => 40, :h => 20, :p => Pixel.new( :s => " ", :b => Color.new(0.8,0.2,0.8) ), :s => true, :b => true )
        $screen.add_element(FloatElement.new(box,5))
        $screen.draw
    elsif key == "l"
        redraw_month("right")
    elsif key == "j"
        redraw_month("left")
    elsif key == "i"
        redraw_month("up")
    elsif key == "k"
        redraw_month("down")
    end
end
