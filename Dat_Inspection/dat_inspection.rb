#!/usr/bin/env ruby
class DatInspection
  def initialize(flug=false)
    @obj = []
    @path = []
    @inspect_log = {'Error'=>{},'Warning'=>{},'Success'=>{}}
    @debug = flug
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
        #_d_puts(cnf 
        #_d_puts("object"
        elsif dat_c =~ /^#obj/ #object commentout
          cnf["obj"] = "next"
        elsif dat_c =~ /^[-]{1,}$/ #split line
          @obj << cnf
          #_d_puts("CT:"+ct.to_s
          ct += 1
          cnf = {}
        elsif dat_c =~ /=> / #icon
          line = dat_c.split(/=> /)
          cnf[line[0]] = line[1].chomp!
        #_d_puts(dat_c
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

      # initialize objct
      @inspect_log['Error'][objc['name']] = []
      @inspect_log['Warning'][objc['name']] = []
      @inspect_log['Success'][objc['name']] = []

      #comment out obj next
      if objc['obj'] == 'next'
        _ad_inspect_log('Warning',objc['name'],'Comment Out')
        _d_puts("\e[33m[Warning]\e[0mComment out")
        next
      end
      
      #target
      _d_puts("Target: "+objc["name"].to_s)
      #name
      if objc['name'].to_s =~ /^[A-z0-9_\-\(\)]{1,}$/ #clear 
        _d_puts("\e[34m[Success]\e[0mName rule")
        #@inspect_log['Success'][objc['name']] << 'namerule'
        _ad_inspect_log('Success',objc['name'],'NameRule')
      else # error
        
        if objc['name'].to_s =~ / / # space use pattern
          _ad_inspect_log('Error',objc['name'],'Space')
          _d_puts("\e[31m[Error]\e[0mName rule using \e[4mspace\e[0m")
        end
        
        if objc['name'].to_s =~ /\// # slash use pattern
          _ad_inspect_log('Error',objc['name'],'Slash')
          _d_puts("\e[31m[Error]\e[0mName rule using \e[4mslash\e[0m")
          next
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
          _d_puts("\e[31m[Error]\e[0mUndefined \e[4mtype\e[0m param")
        end

        #_d_puts("type:"+_type
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
          _d_puts("\e[34m[Success]\e[0mDim Pattern Clear " + dim[2])
          _ad_inspect_log('Success',objc['name'],'Dim')
        else
          _d_puts("\e[31m[Error]\e[0mCan't use dim patter \e[4m"+ dim[2] +"\e[0m")
          _ad_inspect_log('Error',objc['name'],'Dim')

        end
        
      elsif _flug['type']
        _d_puts("\e[33m[Warning]\e[0mCan't inspection in undefined \e[4mtype\e[0m param")
        _ad_inspect_log('Warning',objc['name'],'Type')

      end

      #image check
      ## cur
      _imagePath(objc['cursor'],'Cursor',objc['name'])
      _imagePath(objc['icon'],'Icon',objc['name'])

      images = objc.select{|k,v| k.match(/Image/)}
      images.each{|key,val|
        body = val.split(/\./)
        _imagePath(val,key,objc['name'])
      }

      
      
      
      #pp objc 
      _d_puts("----")
      #_d_puts("inspect"
    }
  end

  def ExportLog #return log
    return @inspect_log
  end

  def _imagePath(line_,key_,name_)
    pos = line_.split(/\./)
    #pp cur
    if File.exist?(@path[0].to_s + '/' + pos[0].to_s + '.png')
      _d_puts("\e[34m[Success]\e[0m" + key_ + " image file exist clear => " + pos[0] + ".png")
      _ad_inspect_log('Success',name_,key_)
    else
      _d_puts("\e[31m[Error]\e[0m" + key_ + " image file don't exist => " + pos[0] + ".png")
      #@inspect_log['Error'][name_] << key_
      _ad_inspect_log('Error',name_,key_)
    end
  end

  def _ad_inspect_log(cat,name,tag)
    @inspect_log[cat.to_s][name.to_s] << tag.to_s
  end
  
  def _d_puts(text) 
    if @debug === true
      puts text
    end
  end
end

#use vars
