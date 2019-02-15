#!/usr/bin/env ruby

require 'optparse'
require 'rb-inotify'
require 'yaml'

class AutoMake_Tools
    Pak = '/pak/'
    MakeObj = 'makeobj_60-2_x64'
    Src_Prefix = '_src'    
    @@w_Dir
    @@w_Mode
    @@e_Dir
    @@c_List = Array.new() 
    
    def initialize
        self.Run_Mode
    end

    def Run_Mode #AutoMake Tools RumMode Setting Get

        #opts
        r_mode =  ARGV.getopts('r:s:m').select{|key,val| val != false && val != nil}
        r_mode.each{|opts,path|
            self.Set_Working_Dir(path,opts)
            self.Mode_Selects(opts)
            
        }       
    end

    def TimeStanp_Create

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

    def Get_Working_Dir
        return @@w_Dir
    end

    def Make_Run(file)
        #file type check
        if file !~ /_src.png/ and file =~ /.png/ then # png match
            png = file
            dat = png.sub(/png/,'dat')
            if !(File.exist?(dat)) then #pair dat not found return 
                return  
            end

            puts "png:#{file}"
            puts "Dat:Ok"
        elsif file !~ /_src.png/ and file =~ /.dat/ then # dat match
            dat = file
            if !(File.exist?(dat.sub(/dat/,'png'))) then #pair png not found return 
                return  
            end
            puts "dat:#{file}"
            puts "Png:ok"
        else
            return
        end
        #mode switch
        if @@w_Mode == "Router" then
            cmd = "#{MakeObj} pak #{@@e_Dir} #{dat}"
        elsif @@w_Mode == "StandAlone"
            e_Dir = File::dirname(dat)+Pak
            puts "Export:"+e_Dir
            cmd = "#{MakeObj} pak #{e_Dir} #{dat}"
        end
        puts system(cmd)
    end

    def File_PairCheck

    end

    def Config_Loader
        
    end

    def Mode_Selects(opts)
        t_RunMode = {r:"Router",s:"StandAlone",m:"makefile"}
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
notif.watch(AMT.Get_Working_Dir,:modify,:close_write,:recursive){
    |fev|
    #puts fev
    file = fev.absolute_name
    AMT.Make_Run(file)
    #puts "#{@@w_Dir} / #{fev.flags} / #{fev.absolute_name}"
}

notif.run
