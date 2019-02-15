#!/usr/bin/env ruby

require 'json'
 
File.open(ARGV[0]) do |file|
  hash = JSON.load(file)
  pp hash
end
