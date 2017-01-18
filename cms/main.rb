#!/usr/bin/ruby -w

RENDER_MAX_LOOPS = 20

require "pp"

require "./page.rb"
require "./chunk.rb"
require "./site.rb"
require "./frontend.rb"

def log(message)
    puts(message)
end

def render_page(id)

    # get page
    page = $site.pages[id]

    # get template
    template_name = page["template"]

    # empty template
    template = "[[ content ]]\n"

    # check if chunk template_name exists
    template = $site.chunks[template_name].content if $site.chunks.has_key?(template_name)

    # fill template with page content
    template.scan(/( *)\[\[ content \]\]/).each do |match|
        indent = match[0].length
        content = page.content.split("\n").map{ |line| " " * indent + line }.join("\n")
        template.sub!(/ *\[\[ content \]\] */, content)
    end

    Frontend.init(page, $site)
    template = Frontend.render(template)

    template
end

# load frontends
Dir["./frontends/*.rb"].each do |file| require file end

puts "-" * 80

# load site
$site = Site.new(".")
puts "-" * 80

# render page
puts render_page("2")








