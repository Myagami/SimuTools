#!/usr/bin/env ruby

require 'optparse'
require 'rb-inotify'
require 'json'
#require_relative 'CUI_Cuts'

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
    @@action_log = {}
    def initialize
      #default run system
      @@on_sys = 'Linux'

      option = {}
      OptionParser.new do |opt|
        opt.on('-r value','role') {|path|
          @@w_Dir = path
          @@e_Dir = path + Pak
          @@e_Dir.gsub!("//","/")
          @@w_Mode = 'Router'
          puts path
          puts "Router"
        }

        opt.on('-s value','standalone'){|path|
          @@w_Dir = path
          @@e_Dir = path
          @@w_Mode = 'Stands'
          
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
        #puts "goods"
        self.Logging_Importer("FileType","")
        self.Command_Genelate(file)
      elsif ft == ".dat" then # dat file
        self.Logging_Importer("FileType","dat")
        self.Logging_Importer("FilePath",file.to_s)
        #puts "dat"
        fn = file.gsub(/\.dat/,'')
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
        cmd = self.Command_Genelate(file)
      elsif ft == ".png" then # png file
        #split dir path for json loading
        jf = file.to_s.split("/")
        puts "png"
        self.Logging_Importer("FileType","dat")
        self.Logging_Importer("FilePath",file.to_s)
        #worker job data getting]
 
        if defined? @@w_Worker then
          if @@w_Worker.has_key?(jf[1]) and @@w_Worker[jf[1]].has_key?(jf[2]) and @@w_Worker[jf[1]][jf[2]].has_key?(jf[3].gsub!(/\.png/,'')) then # exist job
            # [0] = Working Directory
            # [1] = Sub Working Directory
            puts "Job true"
            self.Logging_Importer("Working",file.to_sjf[1],"Worker")
            self.Logging_Importer("Subwork",file.to_sjf[2],"Worker")
            self.Logging_Importer("Target",file.to_sjf[3],"Worker")
            puts "Working:"+jf[1]
            puts "SubWork:"+jf[2]
            puts "Target:"+jf[3]  
            puts @@w_Worker[jf[1]][jf[2]][jf[3]]
            wj = @@w_Worker[jf[1]][jf[2]][jf[3]]
            # image cut
            system("CUI_Cuts.rb #{file.to_s} #{wj["X"]} #{wj["Y"]}")
          else
            print "span"
            puts @@w_Worker
          end
        else
          self.Logging_Importer("Working","Single")
          puts "Single User" 
        end


        #path convert
        if file.to_s =~ /.*_(S|N|E|W)\./ then # cur
          puts "cur"
          dat =  file.gsub(/(?<path>.*)_(S|N|E|W).png/,'\k<path>.dat')
        elsif file.to_s =~ /.*_src/ then # src
          puts "src"
          dat = file.gsub(/(?<path>.*)_src.png/,'\k<path>.dat')
        else # single
          puts "single"
          dat = file.gsub(/\.png/,'.dat')
        end

        if File.exist?(dat) then 
          cmd = self.Command_Genelate(dat)
        else
          puts "dat not found"
          return
        end 

      elsif file =~ /Worker.json/ then #reload Worker.json
        self.Worker_Loading
      end 
      # export system command
      if cmd.nil? == false then
        puts cmd
        self.Logging_Exporter
        puts "-----------------"
      end

    end

    def Command_Genelate(file,path=@@e_Dir)
      puts "Export command"
      if @@w_Mode == "Router" then
        #cmd = "#{MakeObj} pak #{@@e_Dir} #{dat}"
        cmd = "#{MakeObj} pak #{path} #{file}"
        self.Logging_Importer("Mode","Router","Export")
        self.Logging_Importer("Command","#{cmd.to_s}","Export")
        #puts "Router"
        #cmd = "#{MakeObj} pak #{path} #{file}"
      elsif @@w_Mode == "Stands"
        #based = File.dirname(path)
        cmd = "#{MakeObj} pak #{path}/pak/ #{file}"
      end
      return cmd
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
        puts "----------------------"
    end 

    def Logging_Importer(type,message,mother="Root")
      if mother == "Root" then
        @@action_log[:"#{type.to_sym}"] = message
      elsif @@action_log.has_key?(:"#{mother.to_sym}") then
        @@action_log[:"#{mother.to_sym}"].store("#{type.to_s}",message)
      else
        _has = {}
        #puts mother
        _has[:"#{type.to_sym}"] = message
        @@action_log[:"#{mother.to_sym}"] = _has
      end
    end

    def Logging_Exporter
      puts JSON.pretty_generate(@@action_log)
      @@action_log = {}
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
    #puts fev.flags
    file = fev.absolute_name
    AMT.Make_Run(file)
    #puts "#{@@w_Dir} / #{fev.flags} / #{fev.absolute_name}"
  }
end
notif.run
