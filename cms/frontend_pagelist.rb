#!/usr/bin/ruby -w

class FrontendPagelist < Frontend

    def render(content)

        # nothing modified yet
        modified = false

        # find elements like: [[ !pagelist(key1=value1,key2=value2,...) ]]
        content.scan(/( *)\[\[ !pagelist\(([^\(\)]*)\) \]\]/).each do |match|

            # indent of the tag
            indent = match[0].length

            # arguments of the tag
            arguments = match[1].split(",").map{ |item| item.split("=") }.to_h

            # get inner template
            inner_template_name = arguments["template"]
            inner_template = @@site.chunks[inner_template_name].content

            # create pagelist
            pagelist = "<ul>\n"

            @@site.pages.each_value do |page|
                line = inner_template.clone
                line.gsub!(/\[\[ clState \]\]/, "active")
                line.gsub!(/\[\[ clLink \]\]/, "[[ ~#{page.id} ]]")
                line.gsub!(/\[\[ clTitle \]\]/, "[[ ~#{page["title"]} ]]")
                pagelist += line
            end

            # closing html tag
            pagelist += "</ul>\n"

            # indent the pagelist
            pagelist = pagelist.split("\n").map{ |line| " " * indent + line }.join("\n")

            # replace tag in content
            content.sub!(/ *\[\[ !pagelist\(#{match[1]}\) \]\] */, pagelist)

            # something changed
            modified = true
        end

        return content, modified
    end
end
