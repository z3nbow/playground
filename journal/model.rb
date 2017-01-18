#!/usr/bin/env ruby

require "pp"
require "sequel"

class Event

    attr_accessor :text

    def initialize(values)

        raise "ERROR: missing date"  unless values.has_key?(:date)
        @date = values[:date]

        raise "ERROR: missing title" unless values.has_key?(:title)
        @title = values[:title]

        @id       = nil
        @time     = nil
        @end_time = nil
        @text     = nil

        @id   = values[:id]   if values.has_key?(:id)
        @type = values[:type] if values.has_key?(:type)
        @time = values[:time] if values.has_key?(:time)

        #if values.has_key?(:end_date)
        #    @end_date = values[:end_date]
        #else
        #    @end_date = @date
        #end

        @end_date = values[:end_date] if values.has_key?(:end_date)

        @end_time = values[:end_time] if values.has_key?(:end_time)

        @text = values[:text] if values.has_key?(:text)

    end

    def to_h
        hash = {}
        hash[:id]       = @id       if @id
        hash[:date]     = @date     if @date
        hash[:type]     = @type     if @type
        hash[:time]     = @time     if @time
        hash[:end_date] = @end_date if @end_date
        hash[:end_time] = @end_time if @end_time
        hash[:title]    = @title    if @title
        hash[:text]     = @text     if @text
        hash
    end

end

class Journal

    def initialize(filename)
        @db = Sequel.sqlite(filename)
        @events = @db[:events]
    end

    def add_event(event)
        @events.insert(event.to_h)
    end

    def each_event
        @events.each do |event|
            yield Event.new(event)
        end
    end

    def get_month(month, year)
        # select * from events where "yearmonth01" <= date <= "yearmonth31" union
        # select * from events where date <= "yearmonth31" && end_date >= "yearmonth01"
        # order by date, time asc
        d1 = year.to_s + month.to_s + "01"
        d2 = year.to_s + month.to_s + "31"
        #pp @events.where( :date => d1..d2 ).union(@events.where{ (date <= d2) & (end_date >= d1) }).order(:date).sql
        #@events.where( :date => d1..d2 ).union(@events.where{ (date <= d2) & (end_date >= d1) }).order(:date).each do |i|
        #pp @event.where(Sequel.or( (date >= d1) & (date <= d2), ((date <= d2) & (end_date >= d1)) }.order(:date)
        @events.where( :date => (d1..d2) ).or{ (date <= d2) & (end_date >= d1) }.order(:date).each do |i|
            print i[:date] + "  " + i[:title]
            print "  (" + i[:end_date] + ")" if i[:end_date]
            print "\n"
        end


    end

end

def create_test_events(journal)

    words = [ "Tanzen", "Klettern", "Geburtstag", "Wandern", "Kino", "Therme", "Ausflug", "Schwimmen", "Parkour" ]
    years = [ "2017" ]
    number = 500

    r = Random.new

    (1..number).each do |n|
        
        y = years[r.rand(years.length)]
        m = (r.rand(12) + 1).to_s
        m = "0" + m if m.length == 1
        d = (r.rand(31) + 1).to_s
        d = "0" + d if d.length == 1
        t = words[r.rand(words.length)]

        end_date = nil 

        if (r.rand(100) > 94)
            y2 = years[r.rand(years.length)]
            m2 = (r.rand(12) + 1).to_s
            m2 = "0" + m2 if m2.length == 1
            d2 = (r.rand(31) + 1).to_s
            d2 = "0" + d2 if d.length == 1
            end_date = y2+m2+d2
        end

        journal.add_event(Event.new( :date => y+m+d, :end_date => end_date, :title => t ))

        pp n
        
    end


end


j = Journal.new("test.db")

#create_test_events(j)

j.get_month("01", 2017)



