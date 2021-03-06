require "./spec_helper"

def count_lines(file : String) : Int32
  return `wc -l #{file}`.split.first.to_i
end

current = "#{Dir.current}/spec"

describe Bundler do

  it "Javascript asset correct type" do
    js = Bundler::Js.new "#{current}/src/test1.js"
    js.source_type.should eq(Bundler::SourceType::Javascript)
  end

  it "Javascript asset correct name" do
    name = "#{current}/src/test1.js"
    js = Bundler::Js.new name
    js.collect().should eq(name)
  end

  it "JS only bundle" do
    assets = [
      Bundler::Js.new("#{current}/src/test1.js"),
      Bundler::Js.new("#{current}/src/test2.js")]
    bundle = Bundler::Bundle.create "bundle1", assets, "#{current}/dest"
    bundle.build()
    # should have two lines
    count_lines("#{current}/dest/bundle1.js").should eq(2)
  end

  it "JS bundle should remove duplicates" do
    assets = [
      Bundler::Js.new("#{current}/src/test1.js"),
      Bundler::Js.new("#{current}/src/test1.js"),
      Bundler::Js.new("#{current}/src/test2.js")]
    bundle = Bundler::Bundle.create "bundle1", assets, "#{current}/dest"
    bundle.build()
    count_lines("#{current}/dest/bundle1.js").should eq(2)
  end

  it "JS and Typescript mixed bundle" do
    assets = [
      Bundler::Js.new("#{current}/src/test1.js"),
      Bundler::Tsc.new("#{current}/src/test3.ts", "#{current}/src/test3.js"),
      Bundler::Js.new("#{current}/src/test2.js")]
    bundle = Bundler::Bundle.create "bundle1", assets, "#{current}/dest"
    bundle.build()
    count_lines("#{current}/dest/bundle1.js").should eq(3)
  end

  it "JS, CSS and Typescript mixed bundle with duplicates" do
    assets = [
      Bundler::Js.new("#{current}/src/test1.js"),
      Bundler::Js.new("#{current}/src/test1.js"),
      Bundler::Tsc.new("#{current}/src/test3.ts", "#{current}/src/test3.js"),
      Bundler::Css.new("#{current}/src/test4.css"),
      Bundler::Css.new("#{current}/src/test5.css"),
      Bundler::Css.new("#{current}/src/test4.css"),
      Bundler::Js.new("#{current}/src/test2.js")]
    bundle = Bundler::Bundle.create "bundle2", assets, "#{current}/dest"
    bundle.build()
    js_count = count_lines("#{current}/dest/bundle2.js")
    css_count = count_lines("#{current}/dest/bundle2.css")
    (js_count.should eq(3)) && (css_count.should eq(6) )
  end

  it "should create a Bundle based on another Bundle" do
    dst = "#{current}/dest"
    assets1 = [
      Bundler::Js.new("#{current}/src/test1.js"),
      Bundler::Js.new("#{current}/src/test2.js")
    ]
    bundle1 = Bundler::Bundle.create("bundle1", assets1, dst)

    assets2 = [
      Bundler::Js.new("#{current}/src/test1.js"),
      Bundler::Css.new("#{current}/src/test4.css")
    ]
    bundle2 = Bundler::Bundle.create("bundle2", assets2, dst)

    bundle = Bundler::Bundle.create "final", [bundle1, bundle2], dst
    bundle.build()
  end

  it "should compile coffeescript in mixed bundle" do
      assets = [
        Bundler::Js.new("#{current}/src/test1.js"),
        Bundler::Js.new("#{current}/src/test1.js"),
        Bundler::Tsc.new("#{current}/src/test3.ts", "#{current}/src/test3.js"),
        Bundler::Css.new("#{current}/src/test4.css"),
        Bundler::Css.new("#{current}/src/test5.css"),
        Bundler::Css.new("#{current}/src/test4.css"),
        Bundler::Js.new("#{current}/src/test2.js"),
        Bundler::Coffee.new("#{current}/src/test_coffee.coffee", "#{current}/src/test_coffee.js")]
      bundle = Bundler::Bundle.create "bundle3", assets, "#{current}/dest"
      bundle.build()
      js_count = count_lines("#{current}/dest/bundle3.js")
      css_count = count_lines("#{current}/dest/bundle3.css")
      (js_count.should eq(9)) && (css_count.should eq(6) )
    end

    it "should minify output JS" do
      assets = [
        Bundler::Js.new("#{current}/src/test1.js"),
        Bundler::Js.new("#{current}/src/test1.js"),
        Bundler::Tsc.new("#{current}/src/test3.ts", "#{current}/src/test3.js"),
        Bundler::Css.new("#{current}/src/test4.css"),
        Bundler::Css.new("#{current}/src/test5.css"),
        Bundler::Css.new("#{current}/src/test4.css"),
        Bundler::Js.new("#{current}/src/test2.js"),
        Bundler::Coffee.new("#{current}/src/test_coffee.coffee", "#{current}/src/test_coffee.js")]
      bundle = Bundler::Bundle.create "bundle4", assets, "#{current}/dest", minify_js: true
      bundle.build()
      js_count = count_lines("#{current}/dest/bundle4.min.js")
      js_count.should eq(0)
    end



end
