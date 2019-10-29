#!/usr/bin/env ruby

require 'rmagick'
require 'optparse'

class BoxCreate
    @@Image_Ins
    def initialize(tx,ty,sc)
        @@Image_Ins = Magick::Image.new(tx.to_i*sc.to_i , ty.to_i * sc.to_i){

            self.background_color = '#e7ffff'
        }

    end

    def CreateBox(file)
        @@Image_Ins.write(file)
    end
end


option = {}
OptionParser.new do |opt|
    opt.on('-x value','tile X Size') {|val|
        @tx_size = val
    }

    opt.on('-y value','tile Y Size'){|val|
        @ty_size = val
    }

    opt.on('-s value','pak scale') {|val|
        @scale = val
    }

    opt.on('-f value','file name') {|val|
        @file = val
    }
    opt.parse!(ARGV)
end

puts "X:#{@tx_size}"
puts "Y:#{@ty_size}"
puts "Scale:#{@scale}"

#create image
Boxcre = BoxCreate.new(@tx_size,@ty_size,@scale)
Boxcre.CreateBox(@file)
           
