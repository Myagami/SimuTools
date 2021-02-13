require 'date'

class Automake_Tools_Season2
  e_pak = 'pak/'
  # vars
  @w_Dir = 'test' # Working Directory
  @e_Dir = '' # Pak Export Directory
  @w_Mode = '' # Tool Working Mode
  @on_Sys = 'Linux' # System Run envs
  @p_Time = '' # Script Start Time
  @p_File = '' # Prev Working File 
  @w_Flug = false # inotify worked
  @c_Flug = false # file Checked 
  def initialize # class initialize
    # decorate
    

    # start time check
    @p_Time = Time.now
    # options
    option = {}
    OptionParser.new do |opt|
      opt.on('-r value', 'role') do |path|
        @w_Dir = path
        @e_Dir = path + '/pak/'
        @e_Dir.gsub!('//', '/')
        @w_Mode = 'Router'
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
    puts "Mode: " + @w_Mode.to_s
    puts "Working: " + @w_Dir.to_s
    puts "Export: " + @e_Dir.to_s
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
  end

  def FilePair(file) # png file check
    _dat= file.gsub('png','dat')
    puts "dat:" + _dat.to_s
    if File.exist?(_dat)
      @c_Flug = true
    end
  end
  
  def CompilePak # compile pak
    if @c_Flug == true # checked Flug
      puts 'pak'
      cmd = self._Makeobj_Generate
    end
    @c_Flug = false
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
    
  end
end
