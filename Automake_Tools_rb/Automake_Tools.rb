#!/usr/bin/env ruby
# coding: utf-8
# frozen_string_literal: true

require 'bundler/setup'
require 'optparse'
require 'rb-inotify'
require 'json'
require 'date'
#require '/home/karen/Tools/SimuTools/Dat_Inspection/dat_inspection'
require 'DatInspection'
require 'pp'
require 'systemu'
# require_relative 'CUI_Cuts'
# my error class

class AutoMake_Tools
  Pak = '/pak/'
  MakeObj = 'makeobj_60-1'
  Src_Prefix = '_src'
  @@w_Dir
  @@w_Mode
  @@e_Dir
  @@c_List = []
  @@w_Worker
  @@c_Cuts
  @@on_sys = 'null'
  @@action_log = {}
  @dat_inspection 
  def initialize
    # default run system
    @@on_sys = 'Linux'

    option = {}
    OptionParser.new do |opt|
      opt.on('-d', 'dir') do
        # @@w_Dir = path
        # Dir.mkdir('pak',0775)
        puts Dir.getwd
        puts 'WorkSpace Create'
        exit
      end

      opt.on('-r value', 'role') do |path|
        @@w_Dir = path
        @@e_Dir = path + Pak
        @@e_Dir.gsub!('//', '/')
        @@w_Mode = 'Router'
        puts path
        puts 'Router'
      end

      opt.on('-s value', 'standalone') do |path|
        @@w_Dir = path
        @@e_Dir = path
        @@w_Mode = 'Stands'

        puts path
        puts 'standalone'
      end

      opt.on('-m value', 'makefile') do |_v|
        @@w_Mode = 'MakeFile'
        puts 'makefile'
      end

      opt.on('--WSL', 'Workbase in WSL') do |_v|
        @@on_sys = 'WSL'
        puts 'WSL'
      end
      opt.parse!(ARGV)
    end
    @dat_inspection = DatInspection.new()
    self.Worker_Loading
  end

  def run_sys
    @@on_sys
  end

  def Worker_Loading
    worker_f = @@w_Dir + 'Worker.json'
    if File.exist?(worker_f) # pair dat not found return
      File.open(worker_f) do |worker|
        @@w_Worker = JSON.load(worker)
      end
      puts @@w_Worker
      puts 'Loading...'
      nil
    end
  end

  def Get_Working_Dir
    @@w_Dir
  end

  def Make_Run(file, flugs)
    ft = File.extname(file).to_s
    jf = file.to_s.split('/')
    # puts "Flag:" + flugs[0].to_s

    # file delete
    if flugs[0].to_s == 'delete' && file =~ /locking/
      self.Logging_Importer('LockDirectory', jf[1])
      self.Logging_Importer('status', 'Unlock')
      self.Logging_Exporter()
      return 0
    elsif flugs[0].to_s == 'delete' && file =~ /git/
      return 0 
    elsif flugs[0].to_s == 'delete'
      self.Logging_Importer('status', 'delete')
      self.Logging_Importer('FilePath', file.to_s)
      self.Logging_Exporter
    end

    # File Type Checking
    if file =~ /goods/ && (ft == '.dat') # goods dat
      # puts "goods"
      self.Logging_Importer('status', 'update')
      self.Logging_Importer('FileType', 'goods')
      self.Logging_Importer('FilePath', file.to_s)
      self.Command_Genelate(file)
    elsif ft == '.dat' # dat file
      # locking file exist check
      self.Logging_Importer('status', 'update')
      self.Logging_Importer('FileType', 'dat')
      self.Logging_Importer('FilePath', file.to_s)
      if Locking_File_Check(jf[0], jf[1]) == 0
        self.Logging_Importer('Locking', 'true')
        self.Logging_Exporter
        return 0
      end
      # puts "dat"
      fn = file.gsub(/\.dat/, '')

      # inspection dat
      @dat_inspection.LoadFile(file)
      @dat_inspection.Inspection
      d_insp = @dat_inspection.ExportLog
      self.Logging_Importer('Inspector', d_insp)
      d_insp_c = self.Inspection_Error_Check(d_insp)

      # png check
      if File.exist?(fn + '_S_src.png'.to_s) # cut and cur
        self.Logging_Importer('FileExist', 'Cur src file')
        puts 'exist cur src file'
      elsif File.exist?(fn + '_S.png'.to_s) # cur only
        self.Logging_Importer('FileExist', 'Cur file')
      elsif File.exist?(fn + '_src.png'.to_s) # cut only
        self.Logging_Importer('FileExist', 'src file')
      elsif File.exist?(fn + '.png'.to_s) # cut only
        self.Logging_Importer('FileExist', 'single file')
      end
      cmd = self.Command_Genelate(file)
    elsif ft == '.png' # png file
      # split dir path for json loading
      self.Logging_Importer('status', 'update')
      self.Logging_Importer('FileType', 'png')
      self.Logging_Importer('FilePath', file.to_s)
      if Locking_File_Check(jf[0], jf[1]) == 0
        self.Logging_Importer('Locking', 'true')
        self.Logging_Exporter
        return 0
      end
      # worker job data getting]
      if defined? @@w_Worker
        if @@w_Worker.key?(jf[1]) && @@w_Worker[jf[1]].key?(jf[2]) && @@w_Worker[jf[1]][jf[2]].key?(jf[3].gsub!(/\.png/, '')) # exist job
          # [0] = Working Directory
          # [1] = Sub Working Directory
          puts 'Job true'
          self.Logging_Importer('Working', file.to_sjf[1], 'Worker')
          self.Logging_Importer('Subwork', file.to_sjf[2], 'Worker')
          self.Logging_Importer('Target', file.to_sjf[3], 'Worker')
          puts 'Working:' + jf[1]
          puts 'SubWork:' + jf[2]
          puts 'Target:' + jf[3]
          puts @@w_Worker[jf[1]][jf[2]][jf[3]]
          wj = @@w_Worker[jf[1]][jf[2]][jf[3]]
          # image cut
          system("CUI_Cuts.rb #{file} #{wj['X']} #{wj['Y']}")
        else
          print 'span'
          puts @@w_Worker
        end
      else
        self.Logging_Importer('Working', 'Single')
        puts 'Working: Single User'
      end

      # path convert
      if file.to_s =~ /.*_(S|N|E|W)\./ # cur
        puts 'cur'
        dat = file.gsub(/(?<path>.*)_(S|N|E|W).png/, '\k<path>.dat')
      elsif file.to_s =~ /.*_src/ # src
        puts 'src'
        dat = file.gsub(/(?<path>.*)_src.png/, '\k<path>.dat')
      else # single
        puts 'Type:Single Bulding'
        dat = file.gsub(/\.png/, '.dat')
      end
      

      
      if File.exist?(dat)
        #inspection
        @dat_inspection.LoadFile(dat)
        @dat_inspection.Inspection
        d_insp = @dat_inspection.ExportLog
        d_insp_c = self.Inspection_Error_Check(d_insp)
        self.Logging_Importer('Inspector', d_insp)
        cmd = self.Command_Genelate(dat)
      else
        puts 'dat not found'
        return
      end
    elsif file =~ /locking/
      self.Logging_Importer('LockDirectory', jf[1])
      self.Logging_Importer('status', 'Locking')
      self.Logging_Exporter()
    elsif file =~ /Worker.json/ # reload Worker.json
      self.Worker_Loading
    end
    # inspection result check for error

    # export system command
    # puts "Flug: " + d_insp_c.to_s
    if d_insp_c.to_i === 0 && cmd.nil? == false
      puts "make"
      #res = system(cmd.to_s)
      stat, sout, serr = systemu cmd
      #res = `cmd`
      puts "out:\n" + sout
      #self.Logging_Exporter
      #puts '-----------------'
    end
  end

  def Inspection_Error_Check(elog)
    flug = 0 
    pp elog['Error']
    elog['Error'].each do | obj,err|

      if err.length.to_i >= 1 then
        flug = 1
      end
    end
    
    return flug
  end
  
  def Command_Genelate(file, path = @@e_Dir)
    puts 'Export command'
    if @@w_Mode == 'Router'
      # cmd = "#{MakeObj} pak #{@@e_Dir} #{dat}"
      cmd = "#{MakeObj} pak #{path} #{file}"
      self.Logging_Importer('Mode', 'Router', 'Export')
      self.Logging_Importer('Command', cmd.to_s, 'Export')
      # puts "Router"
      # cmd = "#{MakeObj} pak #{path} #{file}"
    elsif @@w_Mode == 'Stands'
      # based = File.dirname(path)
      cmd = "#{MakeObj} pak #{path}/pak/ #{file}"
    end
    cmd
  end

  def Mode_Selects(opts)
    t_RunMode = { r: 'Router', s: 'Stands', m: 'makefile' }
    @@w_Mode = t_RunMode[opts.to_sym]
  end

  def Tool_Propertys
    puts '------Tool Status-----'
    puts 'System:' + @@on_sys
    puts 'Working Directory:' + @@w_Dir
    puts 'Export Directory:' + @@e_Dir
    puts 'Mode:' + @@w_Mode.to_s
    puts '----------------------'
  end

  def Locking_File_Check(root, work)
    return 0 if File.exist?("#{root}/#{work}/locking")
  end

  def Logging_Importer(type, message, mother = 'Root')
    if mother == 'Root'
      @@action_log[:"#{type.to_sym}"] = message
    elsif @@action_log.key?(:"#{mother.to_sym}")
      @@action_log[:"#{mother.to_sym}"].store(type.to_s, message)
    else
      _has = {}
      # puts mother
      _has[:"#{type.to_sym}"] = message
      @@action_log[:"#{mother.to_sym}"] = _has
    end
  end

  def Logging_Exporter
    puts JSON.pretty_generate(@@action_log)
    @@action_log = {}
  end
end
puts "Start:" + Time.now.to_s
AMT = AutoMake_Tools.new
AMT.Tool_Propertys
# AMT.Path_Monitor
sys = AMT.run_sys
notif = INotify::Notifier.new
pr_file = ''
pr_time = 0
if sys == 'WSL'
  notif.watch(AMT.Get_Working_Dir, :close_write, :recursive, :attrib, :remove) do |fev|
  
    # puts fev
    file = fev.absolute_name
    AMT.Make_Run(file, fev.flags)
    # puts "#{@@w_Dir} / #{fev.flags} / #{fev.absolute_name}"
  end
elsif sys == 'Linux'
  notif.watch(AMT.Get_Working_Dir, :close_write, :recursive, :delete) do |fev|
    file = fev.absolute_name
    nw_time = Time.now
    if file =~ /dat|png/
      if pr_time == 0 || pr_file == '' || pr_file != file # not founds / file missmatch
        #time / file check
        puts "Update:" + Time.now.to_s
        puts fev.flags
        puts "pr:" + pr_file
        AMT.Make_Run(file, fev.flags)
        pr_time = nw_time
        pr_file = file
        puts "--------"
      elsif (nw_time - pr_time) <=20
        next
      else
        puts "Update:" + Time.now.to_s
        puts fev.flags
        puts "pr:" + pr_file
        AMT.Make_Run(file, fev.flags)
        pr_time = nw_time
        pr_file = file
        puts "--------"
      end
      #actions
      sleep(15)

    end
    # puts "#{@@w_Dir} / #{fev.flags} / #{fev.absolute_name}"
  end
end
notif.run
