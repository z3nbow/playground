#!/usr/bin/env ruby

require "pp"

require "./journal/model.rb"

$journal = Journal.new("./journal/test.db")

today = Date.today

$action    = :events
$subaction = :list
$period    = :month
$year      = today.year
$month     = today.month
$day       = today.day

if ARGV.length > 0

    argument = ARGV.shift

    if argument == "task"
        $action  = :tasks
        argument = ""
        argument = ARGV.shift if ARGV.length > 0
    end

    if argument.match(/^[1-9][0-9]{0,1}$/)
        month = argument.to_i
        raise "ERROR month > 12" if month > 12
        $month = month
    elsif argument == "add"
        $subaction = :add
    end

end

if $action == :events

    if $subaction == :list && $period == :month
        last_day = Date.new($year, $month, -1).day
        events = $journal.get_events(Date.new($year, $month, 1), Date.new($year, $month, last_day))

        out = Date.new($year, $month, 1).strftime("%^B %Y")
        out += "\n" + "-" * out.length + "\n"
        print out

        (1..last_day).each do |day|
            out = sprintf("%2d", day)
            events[$year][$month][day].each do |event|
                out += "  " + event.title
            end
            puts out   
        end
    end

    if $subaction == :add

        print "Date [today]:    "
        date  = gets

        print "End Date []    : "
        end_date = gets

        print "Title          : "
        title = gets

        print "Text (;;=\\n) []: "
        text = gets

        year  = $year
        month = $month
        day   = $day

        #if date.match(/^[1-9[0-9]{0,1}$/)
        #    day = date.to_i
        #    if 
        #pp date
    end

end
