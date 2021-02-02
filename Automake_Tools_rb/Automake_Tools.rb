#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'optparse'
require 'rb-inotify'
require 'json'
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
      self.Logging_Importer('FileType', 'dat')
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
        puts 'Single User'
      end

      # path convert
      if file.to_s =~ /.*_(S|N|E|W)\./ # cur
        puts 'cur'
        dat = file.gsub(/(?<path>.*)_(S|N|E|W).png/, '\k<path>.dat')
      elsif file.to_s =~ /.*_src/ # src
        puts 'src'
        dat = file.gsub(/(?<path>.*)_src.png/, '\k<path>.dat')
      else # single
        puts 'single'
        dat = file.gsub(/\.png/, '.dat')
      end

      if File.exist?(dat)
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
    # export system command
    if cmd.nil? == false
      system(cmd.to_s)
      self.Logging_Exporter
      puts '-----------------'
    end
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
    puts '------Tool Status------'
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

AMT = AutoMake_Tools.new
AMT.Tool_Propertys
# AMT.Path_Monitor
sys = AMT.run_sys

notif = INotify::Notifier.new

if sys == 'WSL'
  notif.watch(AMT.Get_Working_Dir, :close_write, :recursive, :attrib, :remove) do |fev|
    # puts fev
    file = fev.absolute_name
    AMT.Make_Run(file, fev.flags)
    # puts "#{@@w_Dir} / #{fev.flags} / #{fev.absolute_name}"
  end
elsif sys == 'Linux'
  notif.watch(AMT.Get_Working_Dir, :close_write, :recursive, :delete) do |fev|
    # puts fev.flags
    file = fev.absolute_name
    AMT.Make_Run(file, fev.flags)
    # puts "#{@@w_Dir} / #{fev.flags} / #{fev.absolute_name}"
  end
end
notif.run
