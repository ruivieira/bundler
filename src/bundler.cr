require "./bundler/*"
require "colorize"

module Bundler

  enum SourceType
    Javascript
    Coffeescript
    Typescript
    LESS
    CSS
  end

  abstract class Assets
    getter file, source_type

    def initialize(@file : String, @source_type : SourceType)
    end

    def compile()
    end

    def collect() : String
      return @file
    end
  end

  class Js < Assets
    def initialize(@file : String)
      super(@file, SourceType::Javascript)
    end
  end

  class Tsc < Assets
    def initialize(@file : String, @dest : String)
      super(@file, SourceType::Typescript)
    end

    def compile()
      `tsc #{@file} --outFile #{@dest}`
    end

    def collect() : String
      return @dest
    end
  end

  class Css < Assets
    def initialize(@file : String)
      super(@file, SourceType::CSS)
    end
  end

  class Coffee < Assets
    def initialize(@file : String, @dest : String)
      super(@file, SourceType::Coffeescript)
    end
  end


  class Bundle

    getter assets

    def self.create(name : String, assets : Array(Assets), dest : String)
      return Bundle.new name, assets, dest
    end

    def self.create(name : String, bundle : Bundle, dest : String)
      return self.create(name, [bundle], dest)
    end

    def self.create(name : String, bundles : Array(Bundle), dest : String)
      assets = bundles.map {|b| b.assets}.flatten
      return self.create(name, assets, dest)
    end

    def initialize(@name : String, @assets : Array(Assets), @dest : String)
    end

    def build()
      unique = @assets.uniq {|asset| asset.file }

      # compile all assets
      unique.each {|asset| asset.compile() }

      # javascripts
      javascripts = unique.select {|asset|
        [SourceType::Javascript, SourceType::Typescript].includes? asset.source_type
      }
      # glue everything together
      js_names = javascripts.map{|asset| asset.collect()}
      `cat #{js_names.join(" ")} > #{@dest}/#{@name}.js`

      # CSS
      css =  unique.select {|asset|
        [SourceType::CSS].includes? asset.source_type
      }
      # glue CSS together
      css_names = css.map{|asset| asset.collect()}
      if (!css_names.empty?)
        `cat #{css_names.join(" ")} > #{@dest}/#{@name}.css`
      end
    end

  end

  def self.log(context : String, message : String)
    puts("[#{context.colorize(:green)}\t] #{message}")
  end

  def self.join_js(files : Array(String), dest : String)
    merged_name = "#{Dir.current}/#{dest}"
    self.log("js", "compiling [#{merged_name}]")
    `cat #{files.join(" ")} > #{merged_name}`
    self.log("js", "minifying [#{merged_name}]")
    `$(npm root -g)/uglify-js/bin/uglifyjs #{merged_name} -o #{merged_name}.min.js`
    File.delete("#{merged_name}")
  end

  def self.join_css(files : Array(String), dest : String)
    merged_name = "#{Dir.current}/#{dest}"
    self.log("css", "compiling [#{merged_name}]")
    `cat #{files.join(" ")} > #{merged_name}`
  end

  def self.compile_typescript(files : Array(String))
    files.each do |file|
      self.log("typescript", "compiling #{file}")
      `tsc #{Dir.current}/assets/typescript/#{file} --outDir #{Dir.current}/assets/typescript`
    end
  end

end
