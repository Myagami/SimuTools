#!/usr/bin/env ruby
require 'bundler/setup'
require 'Automake_Tools_Season2'
require 'rb-inotify'
require 'optparse'

AMT_S2 = Automake_Tools_Season2.new
Dir.chdir(AMT_S2.Get_WorkingPath)
notif = INotify::Notifier.new
notif.watch('./',:delete ,:close_write ,:recursive) do |fev|

  file = fev.absolute_name # file path
  #puts file
  #puts fev.flags
  if file =~ /^(?!(.*png|.*dat))/ #xcf | pak thorw
    next
  elsif AMT_S2.Get_WorkingLockFlug(file) === true
    puts 'Directory Locking: ' + File.dirname(file).to_s
    next
  end

  up_Time = Time.now
  # status check

  
  if AMT_S2.WorkFlugCheck == true # checked flug
    df_time = AMT_S2.TimeCheckDef.to_s
    if file.to_s != AMT_S2.Get_WorkingFile.to_s # not Duplicate File update
      puts 'Status: Update'
    elsif file.to_s === AMT_S2.Get_WorkingFile.to_s && df_time.to_i >= 5
      puts 'Status: Updates'
    elsif df_time.to_i <= 5 # before fire time check
      next
    end
  else # first run
    puts 'Status: Update3'
    AMT_S2.TimeCheckDef.to_s
  end

  puts 'TargetFile:' + file.to_s

  # makefile using mode

  if ENV['MODE'] =~ /Make/ # use makefile mode
    puts "make"
    #fn = AMT_S2.FilePair(file).sub!(/.dat/,'')
    cmd = 'make all'
    stat, sout, serr = systemu cmd
    puts sout
    puts serr
    
  else # not make mode
    
    # File Typecheck
    if file =~ /dat/ #dat file
      #time / file check
      puts 'Update:' + up_Time.to_s
      #puts fev.flags
      #puts file
      AMT_S2.DatInspection(file)
    elsif file =~ /png/ #png file
      #time / file check
      puts 'Update:' + up_Time.to_s
      #uts fev.flags
      #puts file
      AMT_S2.FilePair(file)
    end
    
    AMT_S2.CompilePak(file)
    AMT_S2.Set_WorkingFile(file) 
  end

  
  if ENV['MODE'] =~ /Router/
    puts '---------------'
    puts 'Status: CoolDown time 3sec'
    sleep 3
    puts 'Status: CoolDown finish'
    puts '---------------' 
  end
  # puts '#{@@w_Dir} / #{fev.flags} / #{fev.absolute_name}'
end
notif.run
