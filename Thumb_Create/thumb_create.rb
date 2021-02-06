#!/usr/bin/env ruby
# coding: utf-8

#reqire opts
require 'optparse'

#get opts

param = ARGV.getopts('','work:./','export:thumbs/')



puts param 
target_dir = param["work"]
Dir.glob(['**/*.dat'], base: target_dir).each do |file|
  # create file path
  file_path = File.join(target_dir, file)
  puts "#{file_path}"
end
