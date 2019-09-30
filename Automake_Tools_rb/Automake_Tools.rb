#!/usr/bin/env ruby

require 'optparse'
require 'rb-inotify'
require 'json'
require_relative 'CUI_Cuts.rb'
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
    def initialize
      self.Run_Mode
      
    end

    def Run_Mode #AutoMake Tools RumMode Setting Get
      #opts
        r_mode =  ARGV.getopts('r:s:m').select{|key,val| val != false && val != nil}
        r_mode.each{|opts,path|
            self.Set_Working_Dir(path,opts)
            self.Mode_Selects(opts)
            self.Worker_Loading
        }       
    end

    def Set_Working_Dir(path,opts)

        if opts == "r"
            @@w_Dir = path
            @@e_Dir = path + Pak
            @@e_Dir.gsub!("//","/")

        elsif opts == "s"
            @@w_Dir = path
            @@e_Dir = path
        end
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
      png = file.sub(/.dat/,'') 

      #file type check
      if file =~ /goods/ and file =~ /dat/ then # goods dat
        puts "goods"

      elsif file =~ /.dat/ then # dat file
        puts "dat"
        puts file.to_s

        #png check
        if File.exist?(png + "_src.png") then
          puts "exist src file"
        else
          puts "none"
        end

      elsif file =~ /.png/ then # png file
        puts "png"
        puts file.to_s
      end 
      
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
        puts "Working Directory:"+@@w_Dir
        puts "Export Directory:"+@@e_Dir
        puts "Mode:"+ @@w_Mode.to_s
    end 
end 

AMT = AutoMake_Tools.new()
AMT.Tool_Propertys
#AMT.Path_Monitor

notif = INotify::Notifier.new 
notif.watch(AMT.Get_Working_Dir,:close_write,:recursive){
    |fev|
    #puts fev
    file = fev.absolute_name
    AMT.Make_Run(file)
    #puts "#{@@w_Dir} / #{fev.flags} / #{fev.absolute_name}"
}

notif.run
