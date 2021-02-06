#!/usr/bin/env ruby
# coding: utf-8
#

require 'optparse'
require 'json'

class Dat_Definition

  def initialize # 初期化
    puts "Import PNG Props Export dat File"
  end
  
end

#option parse
option = {}
OptionParser.new do |opt|
    opt.on('-x value','role') {|val|
        @x_size = val
    }

    opt.on('-y value','content'){|val|
        @y_size = val
    }

    opt.on('-p value','name') {|val|
        @png_name = val
    }

    opt.on('-w value','workformat'){|val|
      @work_format = val
    }
    
    opt.parse!(ARGV)
end


puts "X:#{@x_size}"
puts "Y:#{@y_size}"
puts "PNG:#{@png_name}"
puts "WORKS:#{@work_format}"
ExtDat = Dat_Definition.new
