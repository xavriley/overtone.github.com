require 'json'
require 'zlib'

module Jekyll
  module LeinClojureDocs
    class DocsPage < Jekyll::Page
      def initialize(site, base, dir, dochash)
        @site = site
        @base = base
        @dir = dir
        @name = "#{dochash['name']}.html"
        @fnname = dochash['name'] # name is already used by jekyll

        self.process(@name)
        self.read_yaml(File.join(base, '_layouts'), 'docs_index.html')
        self.data = self.data.merge(dochash)
        self.data['title'] = @fnname
        self.data['fnname'] = @fnname
        self.data['categories'] = dochash['ns']
      end
    end

    class DocsPageGenerator < Jekyll::Generator
      safe true
      priority :high

      def generate(site)
        puts 'Generating docs from json...'

        docs = JSON.parse(Zlib::GzipReader.open(File.expand_path('../../overtone-0.10-SNAPSHOT.json.gz', __FILE__)).read)

        dir = File.join("docs", docs["name"], docs["version"])
        items = docs["namespaces"]

        items.each do |namespace, methods|
          methods.each do |dochash|
            site.pages << DocsPage.new(site, site.source, File.join(dir, namespace), dochash)
            puts 'Created docs for ' << "#{namespace} (#{dochash['name']})"
          end
        end
      end

    end
  end
end

module Jekyll
  module LeinClojureDocs
    VERSION = "0.0.1"
  end
end
