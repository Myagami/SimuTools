#!/usr/bin/env ruby

require 'inifile'

Read_Conf = ARGV[0]

ini = IniFile.load(Read_Conf)

ini.each_section do |image|
  puts "===#{image}==="
  puts "X:#{ini[image]['X']}"
  puts "Y:#{ini[image]['Y']}"
  puts "Dim:#{ini[image]['Dim']}"
  puts "S_Image:#{ini[image]['S_Image']}"
  puts "E_Image:#{ini[image]['E_Image']}"
  puts "N_Image:#{ini[image]['N_Image']}"
  puts "W_Image:#{ini[image]['W_Image']}"
end
