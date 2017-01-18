#!/usr/bin/ruby -w

class Frontend

    @@frontends = []

    def self.inherited(subclass)
        @@frontends << subclass.new
    end

    def self.init(page, site)
        @@page = page
        @@site = site
    end

    def self.each
        @@frontends.each do |frontend|
            yield frontend
        end
    end

    # iterative version
    # so noch nicht gut, da nach jeder Änderung FrontendVariables aufgerufen werden muss
    def self.render(content)

        modified = true
        loops = 0

        # loop, as long content is changed
        while modified and loops < RENDER_MAX_LOOPS

            # set to false
            modified = false

            # go through all frontends
            each do |frontend|

                # run frontend
                content, modified_temp = frontend.render(content)

                # set modified to true if changes where made
                modified = true if modified_temp
            end

            # one more loop finished
            loops += 1

        end

        content
    end

    # recursive version
    def self.render2(content, depth)

        # go through all frontends
        each do |frontend|

            # run frontend
            content, modified = frontend.render(content, page, site)

            # if changes where made, go deeper
            if modified
                content = render(content, page, site, depth + 1)
            end
        end
        content
    end

end

class FrontendVariable < Frontend
    def render(content)
        #
        modified = false

        #
        content.scan(/\[\[ ([_a-zA-Z0-9]+) \]\]/).each do |match|

            #
            content.sub!(/\[\[ #{match[0]} \]\]/, @@page[match[0]])

            #
            modified = true
        end

        return content, modified
    end
end

class FrontendChunk < Frontend
    def render(content)
        #
        modified = false

        #
        content.scan(/( *)\[\[ &([_a-zA-Z0-9]+) \]\]/).each do |match|
            indent = match[0].length
            chunk_name = match[1]
            if @@site.chunks.has_key?(chunk_name)
                chunk_content = @@site.chunks[chunk_name].content.split("\n").map{ |line| " " * indent + line }.join("\n")
                content.sub!(/ *\[\[ &#{chunk_name} \]\] */, chunk_content)
                modified = true
            else
                log("(WARNING) in [#{@@page["file"]}]: chunk [#{chunk_name}] does not exist")
            end
        end

        #
        return content, modified
    end
end
