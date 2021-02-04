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
  #target
  puts "Target: "+objc["name"].to_s
  #name
  if objc['name'].to_s =~ /^[A-z0-9_\-\(\)]{1,}$/ #clear 
    puts "\e[34m[Success]\e[0mName rule"
  else # error
    if objc['name'].to_s =~ / / # space use pattern
      puts "\e[31m[Error]\e[0mName rule using \e[4mspace\e[0m"
    end
    
    if objc['name'].to_s =~ /\// # slash use pattern
      puts "\e[31m[Error]\e[0mName rule using \e[4mslash\e[0m"
    end
  end

  #type
  if objc['obj'] == 'building'
    if objc.has_key?('Type')
      _type = objc['Type']
    elsif objc.has_key?('dims')
      _type = objc['type']
    end
    
    puts "type:"+_type
  end
  
  #dims
  if objc['obj'] == 'building'
    if objc.has_key?('Dims')
      dim = objc['Dims'].split(/,/)
    elsif objc.has_key?('dims')
      dim = objc['dims'].split(/,/)
    end
  end

  #dim check
  if _type == 'extension'
    if dim[2].to_i == 1 || dim[2].to_i == 2 || dim[2].to_i == 4
      #puts "pt:" + dim[2]
      puts "\e[34m[Success]\e[0mDim Pattern Clear " + dim[2]
    else
      puts "\e[31m[Error]\e[0mCan't use dim patter \e[4m"+ dim[2] +"\e[0m"
    end
  end
  
  pp objc 
  puts "----"
}
