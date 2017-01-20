#!/usr/bin/env ruby

require "pp"
require "date"
require "sequel"

class Event

    attr_accessor :id, :date, :title, :time, :text, :end_date, :end_time, :type

    def initialize(values)
        @id       = values[:id]       
        @date     = values[:date]     
        @title    = values[:title]    
        @time     = values[:time]     
        @text     = values[:text]
        @end_date = values[:end_date] 
        @end_time = values[:end_time]
        @type     = values[:type] 
        @type = 0 unless @type
    end

    def to_h
        hash = {}
        hash[:id]       = @id       if @id
        hash[:date]     = @date     if @date
        hash[:title]    = @title    if @title
        hash[:time]     = @time     if @time
        hash[:text]     = @text     if @text
        hash[:end_date] = @end_date if @end_date
        hash[:end_time] = @end_time if @end_time
        hash[:type]     = @type 
        hash
    end

    def year
        @date[0..3]
    end

    def month
        @date[4..5].sub(/^0/, "")
    end

    def day
        @date[6..7].sub(/^0/, "")
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

    def self.date(year, month, day)
        y = year.to_s
        m = month.to_s
        d = day.to_s
        y = "20" + y if y.length == 2
        y = "200" + y if y.length == 1
        m = "0" + m if m.length == 1
        d = "0" + d if d.length == 1
        y + m + d
    end

    def get_month(year, month)

        day_1  = Journal.date(year, month, 1)
        day_31 = Journal.date(year, month, 31)

        result = {}

        (1..Date.new(year, month, -1).day).each do |day| result[day.to_s] = [] end

        pp result
        
        @events.where(:date => (day_1..day_31)).or{(date <= day_31) & (end_date >= day_1)}.order(:date).each do |entry|
            event = Event.new(entry)
            if not event.end_date
                pp event.day
                result[event.day] << event.id
            end
        end

        result
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

pp j.get_month(17,1)



