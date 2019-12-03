#!/usr/bin/env ruby

require 'optparse'
require 'json'

class Constraint_Checker
  @@const_list = {}
  def initialize
    opts = {}
    OptionParser.new do |opt|
      opt.on('-d value','directory'){|path|
        self._FileCheck(path)
      }
      opt.parse!(ARGV)
    end
  end
  
  def _FileCheck(path)
    Dir.chdir(path)
    Dir.glob("*.dat") do | fn |
        #puts "File:#{fn}"
        File.open(fn) do | cont |
          c_name = {}
          cont.each_line do | line |
            if line.to_s =~ /name/ then
              c_name = line.gsub(/name=/,'').gsub(/\r\n/,'')
              @@const_list[c_name] = {}
              @@const_list[c_name]["Next"] = []
              @@const_list[c_name]["Prev"] = []
            elsif line.to_s =~ /Constraint/ then
              if line.to_s =~ /Next|next/ then
                @@const_list[c_name]["Next"].push(line.gsub!(/.*\=/,'').gsub(/\r\n/,''))
                #puts "\t"+line                                 
              elsif line.to_s =~ /Prev|prev/ then
                @@const_list[c_name]["Prev"].push(line.gsub!(/.*\=/,'').gsub(/\r\n/,''))
                  #puts "\t"+line               
              end
            end
          end
        end
      end
    pp @@const_list
  end
end

#system start
CCT = Constraint_Checker.new()
#CCT.FileChecker()
