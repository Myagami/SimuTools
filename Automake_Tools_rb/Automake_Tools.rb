#!/usr/bin/env ruby

require 'optparse'
require 'rb-inotify'
require 'json'
require_relative 'CUI_Cuts.rb'

#my error class

class AutoMake_Tools
    Pak = '/pak/'
    MakeObj = 'makeobj_60-2_x64'
    Src_Prefix = '_src'    
    @@w_Dir
    @@w_Mode
    @@e_Dir
    @@c_List = Array.new()
    @@w_Worker
    @@c_Cuts
    @@on_sys = 'null'
    def initialize
      #default run system
      @@on_sys = 'Linux'

      option = {}
      OptionParser.new do |opt|
        opt.on('-r value','role') {|path|
          @@w_Dir = path
          @@e_Dir = path + Pak
          @@e_Dir.gsub!("//","/")
          @@w_Mode = 'Routor'
          puts path
          puts "role"
        }

        opt.on('-s value','standalone'){|path|
          @@w_Dir = path
          @@e_Dir = path
          @@w_Mode = 'Stand'
          
          puts path
          puts "standalone"
        }

        opt.on('-m value','makefile') {|v|
          @@w_Mode = 'MakeFile'  
          puts "makefile"
        }

        opt.on('--WSL','Workbase in WSL'){|v| 
          @@on_sys = 'WSL'         
          puts "WSL"
        }
        opt.parse!(ARGV)
      end
      self.Worker_Loading
      
    end

    def run_sys
      return @@on_sys
    end

    def Worker_Loading
      worker_f = @@w_Dir + "Worker.json"
      if (File.exist?(worker_f)) then #pair dat not found return 
        File.open(worker_f){|worker|
          @@w_Worker = JSON.load(worker)
        }
        puts @@w_Worker
        puts "Loading..."
        return  
      end

    end
    
    def Get_Working_Dir
        return @@w_Dir
    end

    def Make_Run(file)
      ft = File.extname(file).to_s
      if file =~ /goods/ and ft == ".dat" then # goods dat
        puts "goods"
      elsif ft == ".dat" then # dat file
        puts "dat"
        puts file.to_s
        fn = file.gsub!(/\.dat/,'')
        #png check
        if File.exist?(fn + "_S_src.png".to_s) then # cut and cur
          puts "exist cur src file"
        elsif File.exist?(fn + "_S.png".to_s) then # cur only
          puts "exist cur file"
        elsif File.exist?(fn + "_src.png".to_s) then # cut only
          puts "exits src file"
        elsif File.exist?(fn + ".png".to_s) then # cut only
          puts "exists single file"
        end
      elsif ft == ".png" then # png file
        #split dir path for json loading
        jf = file.to_s.split("/")
              

        puts "png"
        puts file.to_s
        if file.to_s =~ /.*_(S|N|E|W)/ then # cur
          puts "cur"
          puts file.gsub!(/(?<path>.*)_(S|N|E|W).png/,'\k<path>.dat')
        elsif file.to_s =~ /.*_src/ then # src
          puts "src"
          puts file.gsub!(/(?<path>.*)_src.png/,'\k<path>.dat')
        else # single
          puts "single"
          puts file.gsub!(/\.dat/,'.png')
        end

        #worker job data getting 
        
        if @@w_Worker.has_key?(jf[1]) and @@w_Worker[jf[1]].has_key?(jf[2]) and @@w_Worker[jf[1]][jf[2]].has_key?(jf[3].gsub!(/\.png/,''))  then
          #[0] = Working Directory
          #[1] = Sub Working Directory
          puts "Job true"
          puts "Working:"+jf[1]
          puts "SubWork:"+jf[2]
          puts "Target:"+jf[3]  
          puts @@w_Worker[jf[1]][jf[2]][jf[3]]
        else
          puts "Job false"
        end

      elsif file =~ /Worker.json/ then #reload Worker.json
        self.Worker_Loading
      end 
      
      #image cut
      #search Worker Tree
      

      # #file type check
      #   if file !~ /_src.png/ and file =~ /.png/ then # png match
      #     png = file
      #     dat = png.sub(/png/,'dat')
      #     if !(File.exist?(dat)) then #pair dat not found return 
      #       return  
      #     end
      #     #json check
      #     jf = file.to_s.split("/")
      #       jf.shift  
      #       puts "---------"
      #       puts jf
      #       puts "---------"
      #       puts "png:#{file}"
      #       puts "dat:Ok"
      #       if @@w_Worker.has_key?(jf[0]) and @@w_Worker[jf[0]].has_key?(jf[1])  then
      #         puts "Dir:"+jf[0]
      #         puts "File:"+jf[1]
      #         puts "X:" + @@w_Worker[jf[0]][jf[1]]['X'].to_s + " Y:" + @@w_Worker[jf[0]][jf[1]]["Y"].to_s
      #            c_Cuts = Cui_Cuts.new(file.to_s)
      #            c_Cuts.XY_Pos(@@w_Worker[jf[0]][jf[1]]["X"].to_i,@@w_Worker[jf[0]][jf[1]]["Y"].to_i)
      #            c_Cuts.Image_Prpos
      #            c_Cuts.Image_Cuts
      #            c_Cuts.Image_Write
      #       else
      #         puts "Target Not found"
      #       end
      #   elsif file !~ /_src.png/ and file =~ /.dat/ then # dat match
      #     dat = file
      #     if !(File.exist?(dat.sub(/\.dat/,'_src.png'))) then #exist src file
      #       puts "Files"
      #     else
      #       if !(File.exist?(dat.sub(/dat/,'png'))) then #exist base png file
      #         puts dat.sub(/dat/,'png')
      #         puts "Pair file not found for single"
      #         return
      #       end
      #     end
      #     puts "dat:#{file}"
      #     puts "png:ok"
      #   elsif file =~ /Worker.json/ then
      #     self.Worker_Loading
      #   else
      #     return
      #   end

      #   #mode switch
      #   if @@w_Mode == "Router" then
      #     #cmd = "#{MakeObj} pak #{@@e_Dir} #{dat}"
      #     cmd = "#{MakeObj} pak #{@@e_Dir} #{dat}"
      #   elsif @@w_Mode == "Stands"
      #     puts file
      #     e_Dir = File::dirname(dat)+Pak
      #     puts "Export:"+e_Dir
      #     #cmd = "#{MakeObj} pak #{e_Dir} #{dat}"
      #     cmd = "#{MakeObj} pak #{@@e_Dir} #{dat}"
      #   end
      #   puts system(cmd)
      #   #puts cmd
    end

    def Mode_Selects(opts)
        t_RunMode = {r:"Router",s:"Stands",m:"makefile"}
        @@w_Mode = t_RunMode[opts.to_sym]
        
    end
    
    def Tool_Propertys
        puts "------Tool Status------"
        puts "System:"+@@on_sys
        puts "Working Directory:"+@@w_Dir
        puts "Export Directory:"+@@e_Dir
        puts "Mode:"+ @@w_Mode.to_s
    end 
end 

AMT = AutoMake_Tools.new()
AMT.Tool_Propertys
#AMT.Path_Monitor
sys =  AMT.run_sys


notif = INotify::Notifier.new

if sys == 'WSL' then
  notif.watch(AMT.Get_Working_Dir,:close_write,:recursive,:attrib){
    |fev|
    #puts fev
    file = fev.absolute_name
    AMT.Make_Run(file)
    #puts "#{@@w_Dir} / #{fev.flags} / #{fev.absolute_name}"
  }
elsif sys == 'Linux' then
  notif.watch(AMT.Get_Working_Dir,:close_write,:recursive){
    |fev|
    #puts fev
    file = fev.absolute_name
    AMT.Make_Run(file)
    #puts "#{@@w_Dir} / #{fev.flags} / #{fev.absolute_name}"
  }
end
notif.run
