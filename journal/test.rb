#!/usr/bin/env ruby

require "pp"
require "date"
require "sequel"
require "./model.rb"

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
        #if (r.rand(100) > 94)
        #    y2 = years[r.rand(years.length)]
        #    m2 = r.rand(12) + 1
        #    d2 = r.rand(Date.new(y2, m2, -1).day) + 1
        #    end_date = Date.new(y2, m2, d2)
        #end

        journal.add_event(Event.new( :date => date, :end_date => end_date, :title => t ))

        pp n
        
    end


end


j = Journal.new("test.db")

create_test_events(j)

#pp j.get_month(Date.new(2017,1,1),Date.new(2017,1,1))



