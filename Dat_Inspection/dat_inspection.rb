#!/usr/bin/env ruby

#debug
require 'pp'

#use vars
dat_f = ARGV[0]
obj = []
ct = 0 
cnf = {}

#puts dat_f

#read datfile phese
File.open(dat_f) do | dat_l |
  dat_l.each_line do |dat_c| #object 
    if dat_c =~ /obj/
      cnf["obj"] = dat_c.split(/=/)[1].chomp!
      #puts cnf 
      #puts "object"
    elsif dat_c =~ /^[-]{1,}$/ #split line
      obj << cnf
      #puts "CT:"+ct.to_s
      ct += 1
      cnf = {}
    elsif dat_c =~ /=> / #icon
      line = dat_c.split(/=> /)
      cnf[line[0]] = line[1].chomp!
      #puts dat_c
    else #other 
      line = dat_c.split(/=/)
      cnf[line[0]] = line[1].chomp!
    end
    
  end
end

#pp obj

#inspection phase
obj.each{|objc| # 1 object unit each
  objc.each{|key,val| # parse key and value
    puts "Key:"+key+" = "+val
  }
  #pp objc 
  puts "----"
}
