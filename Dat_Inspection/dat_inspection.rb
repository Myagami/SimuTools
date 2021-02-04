#!/usr/bin/env ruby

#debug
require 'pp'

class DatInspection
  def initialize()
    @obj = []
    @path = []
    @inspct_log = {'Error'=>{},'Warning'=>{},'Success'=>{}}
    
  end
  
  def LoadFile(dat_f) #load dat file
    # use args
    ct = 0 
    cnf = {}

    # file path
    @path = File.split(dat_f)

    #read datfile phese
    File.open(dat_f) do | dat_l |
      dat_l.each_line do |dat_c| #object 
        if dat_c =~ /^obj/
          cnf["obj"] = dat_c.split(/=/)[1].chomp!
        #puts cnf 
        #puts "object"
        elsif dat_c =~ /^#obj/ #object commentout
          cnf["obj"] = "next"
        elsif dat_c =~ /^[-]{1,}$/ #split line
          @obj << cnf
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
  end

  def Inspection
    @obj.each{|objc| # 1 object unit each
      _flug = {}
      #comment out obj next
      if objc['obj'] == 'next'
        next
      end

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
        else
          _flug['type'] = true
          puts "\e[31m[Error]\e[0mUndefined \e[4mtype\e[0m param"
        end

        #puts "type:"+_type
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
        _dim = ['1','2','4','8','16']
        if dim[2].to_i == 1 || dim[2].to_i == 2 || dim[2].to_i == 4
          #if _dim.include?(dim[2].to_s)
          #puts "pt:" + dim[2]
          puts "\e[34m[Success]\e[0mDim Pattern Clear " + dim[2]
        else
          puts "\e[31m[Error]\e[0mCan't use dim patter \e[4m"+ dim[2] +"\e[0m"
        end
        
      elsif _flug['type']
        puts "\e[33m[Warning]\e[0mCan't inspection in undefined \e[4mtype\e[0m param"
      end

      #image check
      ## cur
      _imagePath(objc['cursor'],'Cursor')
      _imagePath(objc['icon'],'Icon')

      images = objc.select{|k,v| k.match(/Image/)}
      images.each{|key,val|
        #puts key + ":" + val
        body = val.split(/\./)
        if File.exist?(@path[0].to_s + '/' + body[0].to_s + '.png')
          puts "\e[34m[Success]\e[0mBody image file exist clear => " + body[0] + ".png"
        else
          puts "\e[31m[Error]\e[0mBody image file don't exist => " + body[0] + ".png"
        end
      }

      
      
      
      #pp objc 
      puts "----"
      puts "inspect"
    }
  end

  def ExportLog #return log
    return @inspect_log
  end

  def _imagePath(line,key)
    pos = line.split(/\./)
    #pp cur
    if File.exist?(@path[0].to_s + '/' + pos[0].to_s + '.png')
      puts "\e[34m[Success]\e[0m" + key + " image file exist clear => " + pos[0] + ".png"
    else
      puts "\e[31m[Error]\e[0m" + key + " image file don't exist => " + pos[0] + ".png"
    end
  end
end

#use vars
di = DatInspection.new()
di.LoadFile(ARGV[0])
di.Inspection()
di.ExportLog()
