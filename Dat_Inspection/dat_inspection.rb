#!/usr/bin/env ruby

dat_f = ARGV[0]
obj = []
ct = 0 
cnf = {}

puts dat_f

#read datfile
File.open(dat_f) do | dat_l |
  dat_l.each_line do |dat_c| #object 
    if dat_c =~ /obj/
      cnf["obj"] = dat_c.split(/=/)[1].chomp!
      puts cnf 
      puts "object"
    elsif dat_c =~ /^[-]{1,}$/ #split line
      obj << cnf
      puts "CT:"+ct.to_s
      ct += 1
      cnf = {}
    elsif dat_c =~ /=> / #icon
      puts dat_c
    else #other 
      line = dat_c.split(/=/)
      cnf[line[0]] = line[1].chomp!
    end
    
  end
end

puts obj
