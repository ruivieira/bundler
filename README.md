# bundler

Web assets bundler for Crystal. 

(Pre-alpha. API will break.)

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  bundler:
    github: ruivieira/bundler
```

### Dependencies

Minifying Javascript will depend on `uglify-js`. Install it with

```
npm install -g uglify-js
```
Compiling Coffeescript and Typescript will depend on the respective npm packages

```
npm install -g coffee-script
npm install -g typescript

```


## Usage


```crystal
require "bundler"
```

### Create a simple Bundle

```crystal
bootstrap = [
	Bundler::Js.new("assets/bootstrap/js/bootstrap.js"),
    Bundler::Css.new("assets/bootstrap/css/bootstrap.css")
]

jquery = [Bundler::Js.new(assets/"jquery-2.1.4.js")]

bundle = Bundler::Bundle.create("blog", 
   bootstrap + jquery,
   "public/js")
```

This will create a bundled `blog.css` and `blog.js` under `public/`.

### Combining `Bundle`s

Let's say your blog uses Bootstrap for layout and Prism for syntax highlighting.

```crystal
bootstap = Bundler::Bundle.create("bootstrap", 
	[Bundler::Js.new("assets/bootstrap/js/bootstrap.js"),
    Bundler::Css.new("assets/bootstrap/css/bootstrap.css")],
   "public")

prism = Bundler::Bundle.create("prism", 
	[Bundler::Js.new("assets/prism.js"),
    Bundler::Css.new("assets/prism.css")],
   "prism")
```

You can create a `blog` bundle. This will output `blog.css` and `blog.js` ignoring the initial bundle's outputs.

```crystal
blog = Bundler::Bundle.create("blog", bootstrap + prism, "public")
# creates public/blog.{css, js}
```

### Minifying output

Given a mixed bundle

```crystal
  assets = [
        Bundler::Js.new("test1.js"),
        Bundler::Js.new("test1.js"),
        Bundler::Tsc.new("test3.ts", "test3.js"),
        Bundler::Css.new("test4.css"),
        Bundler::Css.new("test5.css"),
        Bundler::Css.new("test4.css"),
        Bundler::Js.new("test2.js"),
        Bundler::Coffee.new("test_coffee.coffee", "test_coffee.js")]
      bundle = Bundler::Bundle.create "bundle", assets, "dest", minify_js: true
      bundle.build()
```

This will create `bundle.css` and `bundle.{js, min.js}`. Note that duplicate (with respect to source file name) assets will just be included once.

## Development


## Contributing

1. Fork it ( https://github.com/ruivieira/bundler/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [ruivieira](https://github.com/ruivieira) (Rui Vieira) - creator, maintainer
