#!/usr/bin/env ruby

dir = File.dirname(__FILE__)
Dir["#{dir}/vendor/*/lib"].each{|lib| $LOAD_PATH.unshift(lib) }

require 'json'
require 'rack'
require 'innate'
require 'ramaze'

# Add the directory this file resides in to the load path, so you can run the
# app from any other working directory
$LOAD_PATH.unshift(__DIR__)

# Initialize controllers and models
require 'controller/init'
require 'model/init'

Ramaze.start(:adapter => :webrick, :file => __FILE__) if __FILE__ == $0
