require "rubygems"
require "bundler/setup"

Bundler.require

$LOAD_PATH.unshift(File.expand_path("../lib", __FILE__))

require "app"

map("/assets") { run App.sprockets }
map("/") { run App }
