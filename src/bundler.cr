require "./bundler/*"
require "colorize"

module Bundler

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
