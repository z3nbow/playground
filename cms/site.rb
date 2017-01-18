#!/usr/bin/ruby -w

class Site

    attr_reader :pages
    attr_reader :chunks
    attr_reader :global

    def initialize(path)
        @path   = path
        @pages  = {}
        @chunks = {}
        @global = {}
        load_global
        load_chunks(path + "/chunks")
        load_pages(path + "/site", @global)
    end

    # load global variables
    def load_global
        if File.exist?(@path + "/site.conf")
            File.read(@path + "/site.conf").scan(/\[\[ ([_a-zA-Z0-9]+) = (\d+|".*?") \]\]/).each do |match|
                @global[match[0]] = match[1].sub(/^"/, "").sub(/"$/, "")
                log("log: loaded global variable [#{match[0]}] = [#{global[match[0]]}]")
            end
        end
    end

    # load all chunks into @chunks (recursive, so doesn't use @path)
    def load_chunks(path)

        # loop over all files
        Dir[path + "/*"].each do |file|

            # check if directory
            if File.directory?(file)

                # go deeper
                load_chunks(file)

            # check if file
            elsif File.file?(file)

                # check if chunk
                if Chunk.is_chunk?(file)

                    # add chunk to @chunks
                    chunk = Chunk.new(file)
                    @chunks[chunk.name] = chunk
                    log("log: loaded chunk [#{chunk.name}]")
                end
            end
        end
    end

    # load all pages into @pages (recursive, so doesn't use @path)
    def load_pages(path, parent)

        # check if index.html exists
        if File.exist?(path + "/index.html")

            # check if index.html has an id
            if Page.is_page?(path + "/index.html")

                # add index.html to @pages
                page = Page.new(path + "/index.html")
                page.parent = parent
                parent = page
                @pages[page.id] = page
                log("log: loaded page [#{page["file"]}] with id [#{page.id}]")
            end
        end

        # load all other files and directories
        Dir[path + "/*"].delete_if{ |f| f.match(/index\.html$/) }.each do |file|

            # check if directory
            if File.directory?(file)

                # go deeper
                load_pages(file, parent)

            # check if file
            elsif File.file?(file)

                # check if page has an id
                if Page.is_page?(file)

                    # add page to @pages
                    page = Page.new(file)
                    page.parent = parent
                    @pages[page.id] = page
                    log("log: loaded page [#{page["file"]}] with id [#{page.id}]")
                end
            end
        end
    end

end
