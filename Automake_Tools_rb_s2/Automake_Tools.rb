#!/usr/bin/env ruby

require 'Automake_Tools_Season2'
require 'rb-inotify'
require 'optparse'

AMT_S2 = Automake_Tools_Season2.new

notif = INotify::Notifier.new
notif.watch(AMT_S2.Get_WorkingPath, :close_write, :recursive, :delete) do |fev|
  file = fev.absolute_name # file path
  up_Time = Time.now
  # status check
  if AMT_S2.WorkFlugCheck == true # checked flug
    df_time = AMT_S2.TimeCheckDef.to_s
    if file.to_s != AMT_S2.Get_WorkingFile.to_s # not Duplicate File update
      puts 'Status: Update'
    elsif file.to_s === AMT_S2.Get_WorkingFile.to_s && df_time.to_i >= 15
      puts 'Status: Updates'
    elsif df_time.to_i <= 15 # before fire time check
      next
    end
  else # first run
    puts 'Status: Update3'
    AMT_S2.TimeCheckDef.to_s
  end

  puts 'TargetFile:' + file.to_s
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

  AMT_S2.CompilePak
  AMT_S2.Set_WorkingFile(file) 
  puts '---------------'
  # puts '#{@@w_Dir} / #{fev.flags} / #{fev.absolute_name}'
end
notif.run
