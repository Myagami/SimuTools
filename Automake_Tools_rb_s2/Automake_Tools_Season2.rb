require 'date'
require 'dotenv'
require 'systemu'

class Automake_Tools_Season2
  e_pak = 'pak/'
  # vars
  @w_Dir = 'test' # Working Directory
  @e_Dir = '' # Pak Export Directory
  @on_Sys = 'Linux' # System Run envs
  @p_Time = '' # Script Start Time
  @p_File = '' # Prev Working File
  @n_File = '' # Now Working File
  @w_Flug = false # inotify worked
  @c_Flug = false # file Checked 
  def initialize # class initialize
    # decorate
    

    # start time check
    @p_Time = Time.now
    # options
    option = {}
    OptionParser.new do |opt|
      opt.on('-w value', 'workdir') do |path|
        @w_Dir = path
        Dotenv.load(
          File.join(@w_Dir,'.env')
        )
        @e_Dir = path + '/' + ENV['EXPORT'].to_s
        @e_Dir.gsub!('//', '/')
        #puts path
      end
      opt.parse!(ARGV)
    end

    self.SystemStatus # Start System Status
  end

  # start message

  def SystemStatus
    # decorate start
    puts "+-------------------+"
    puts "Mode: " + ENV['MODE']
    puts "Working: " + @w_Dir.to_s
    puts "Export: " + @e_Dir.to_s
    puts "Pak: " + ENV['PAK']
    # decorate end
    puts "+-------------------+"
  end

  # inotify fire
  def Get_WorkingPath
    return @w_Dir
  end                                                                                        

  def WorkFlugCheck
    return @w_Flug
  end
  
  def TimeCheckDef
    n_Time = Time.now
    df_Time = n_Time.to_i - @p_Time.to_i
    @p_Time = n_Time
    @w_Flug = true
    return df_Time
  end
  
  def DatInspection(file) # dat inspection
    @c_Flug = true
    @n_File = file
  end

  def FilePair(file) # png file check
    _dat= file.gsub('png','dat')
    if File.exist?(_dat)
      @c_Flug = true
      @n_File = _dat
    end
  end
  
  def CompilePak(file) # compile pak
    if @c_Flug == true # checked Flug
      cmd = self._Makeobj_Generate
      puts "Compile Target: " + @n_File.to_s
    end
    @c_Flug = false
  end

  def Get_WorkingLockFlug(file) # directory lock file exist check
    d_name = File.dirname(file)
    if File.exist?(d_name.to_s + '/locking')    
      return true    
    else
      return false
    end
  end
  
  def Set_WorkingFile(file) # Worked File Set
    @p_File = file
  end

  def Get_WorkingFile # Prev Worked File Get
    return @p_File 
  end

  def d_puts(txt)
    puts txt
  end

  # inside methods
  # get category

  
  # Create
  def _Makeobj_Generate
    cmd = ENV['MAKEOBJ'] + ' ' + ENV['PAK'] +' ' + @e_Dir.to_s + ' ' + @n_File.to_s

    puts "Export Command: " + cmd
    stat, sout, serr = systemu cmd

    #puts stat
    puts sout
    puts serr
  end
end
