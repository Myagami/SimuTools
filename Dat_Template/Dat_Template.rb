#!/usr/bin/env ruby

#required
#require 'rmagick'
require 'optparse'
require 'json'
#use args

class Dat_Template


    def initialize
        self.get_Opts
    end 

    def get_Opts
        r_mode =  ARGV.getopts('n:x:y:j:').select{|key,val| val != false && val != nil}
        puts r_mode
    end
end

dt = Dat_Template.new