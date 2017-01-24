#!/usr/bin/env ruby

require "pp"
require "date"
require "sequel"

class Event

    attr_accessor :id, :type, :date, :time, :title, :text, :end_date, :end_time, :data

    def initialize(values)
        @id = values[:id]

        @type = values[:type] ? values[:type] : 0

        @date = nil
        @date = values[:date] if values[:date].kind_of?(Date)
        @date = Date.parse(values[:date]) if values[:date].kind_of?(String)

        @time  = values[:time]     
        @title = values[:title]    
        @text  = values[:text]

        
        @end_date = nil
        @end_date = values[:end_date] if values[:end_date].kind_of?(Date)
        @end_date = Date.parse(values[:end_date]) if values[:end_date].kind_of?(String)
        
        if @end_date
            @end_date = nil if @end_date < @date 
        end

        @end_time = values[:end_time]

        # hash for storing additional data (different frontends)
        @data = {}

    end

    def to_h
        hash = {}
        hash[:id]       = @id       if @id
        hash[:date]     = @date.strftime("%Y%m%d") if @date
        hash[:title]    = @title    if @title
        hash[:time]     = @time     if @time
        hash[:text]     = @text     if @text
        hash[:end_date] = @end_date.strftime("%Y%m%d") if @end_date
        hash[:end_time] = @end_time if @end_time
        hash[:type]     = @type 
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

    def self.date2string(date)
        y = date.year.to_s
        m = date.month.to_s
        d = date.day.to_s
        y = "20" + y if y.length == 2
        y = "200" + y if y.length == 1
        m = "0" + m if m.length == 1
        d = "0" + d if d.length == 1
        y + m + d
    end

    def get_month(date_1, date_2 = nil)
        
        date_2 = date_1 unless date_2

        date_1_str = Journal.date2string(date_1)
        date_2_str = Journal.date2string(date_2)

        result = {}

        d = date_1.clone

        while  d <= date_2
            result[d.year] = Hash.new unless result[d.year]
            result[d.year][d.month] = Hash.new unless result[d.year][d.month]
            result[d.year][d.month][d.day] = Array.new unless result[d.year][d.month][d.day]
            d += 1
        end
        
        @events.where(:date => (date_1_str..date_2_str)).or{(date <= date_2_str) & (end_date >= date_1_str)}.order(:date).each do |entry|
            event = Event.new(entry)
            if not event.end_date
                result[event.date.year][event.date.month][event.date.day] << event
            else
                d = event.date.clone
                #while d <= date_2 and d <= event.end_date
                #    result[d.year][d.month][d.day] << event.id
                #    d += 1
                #end
            end
        end

        result
    end

end

def create_test_events(journal)

    words = [ "Tanzen", "Klettern", "Geburtstag", "Wandern", "Kino", "Therme", "Ausflug", "Schwimmen", "Parkour" ]
    years = [ 2017 ]
    number = 500

    r = Random.new

    (1..number).each do |n|

        t = words[r.rand(words.length)]
        
        y = years[r.rand(years.length)]
        m = r.rand(12) + 1
        d = r.rand(Date.new(y, m, -1).day) + 1
        date = Date.new(y, m, d)

        end_date = nil 
        if (r.rand(100) > 94)
            y2 = years[r.rand(years.length)]
            m2 = r.rand(12) + 1
            d2 = r.rand(Date.new(y2, m2, -1).day) + 1
            end_date = Date.new(y2, m2, d2)
        end

        journal.add_event(Event.new( :date => date, :end_date => end_date, :title => t ))

        pp n
        
    end


end


#j = Journal.new("test.db")

#create_test_events(j)

#pp j.get_month(Date.new(2017,1,1),Date.new(2017,1,1))



