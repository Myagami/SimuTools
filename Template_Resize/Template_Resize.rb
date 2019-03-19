#!/usr/bin/env ruby

require 'rmagick'

In_Image = ARGV[0] 
X_Size = ARGV[1] 
Y_Size  = ARGV[2] 

class Template_Resize
  def initialize(e_image)
    @e_Image = e_image
    @image = Magick::ImageList.new(@e_Image)
    puts "Edit: #{@e_Image}"
  end

  def XY_Pos(x_size,y_size)
      @X_Size = x_size
      @Y_Size = y_size
      puts "X:#{@X_Size} Y:#{@X_Size}"
  end

  def Image_Props
    puts "----Prop---"
    puts "Export:#{@e_Image}"
    puts "Width:#{@image.columns}"
    puts "Height:#{@image.rows}"
    puts "X:#{@X_Size}"
    puts "Y:#{@Y_Size}"
    puts "------------"
    puts "\n"
    
    
    #math crop area
    @Crop_X = (@X_Size.to_i - 1) * 32
     if @Y_Size.to_i == 1 then
       @Crop_Y = (@X_Size.to_i * 32) + 16
     elsif @Y_Size.to_i > @X_Size.to_i then
       puts "Y > X"
       @Crop_Y = (@Y_Size.to_i % 2).to_i == 0 ? @Y_Size.to_i * 32 : ((@Y_Size.to_i - 1) * 32) + 16
     elsif @Y_Size.to_i == @X_Size.to_i then
       @Crop_Y = ((@Y_Size.to_i + 1) * 32)
     else
       puts "Y < X"
       #@Crop_Y = @Y_Size.to_i <= 3 ? ((@X_Size.to_i) * 32) + 16 : ((@X_Size.to_i - 1) * 32) + 32
       @Crop_Y = (@X_Size.to_i % 2).to_i == 0 ? (@X_Size.to_i - 1) * (@Y_Size.to_i * 16) : ((@X_Size.to_i + 1) * 32) - 16
     end
    
    puts "----Crop---"
    puts "X_Pos:#{@Crop_X.to_i}"
    puts "Y_Pos:#{@Crop_Y.to_i}"
    puts "------------"

    @c_Image = @image.crop(Magick::SouthEastGravity,0,0,@image.columns.to_i,@Crop_Y.to_i,true){
      self.background_color='red'
    }
  end

  def Image_Write
    e_Image = File.basename(@e_Image)
    @c_Image.write("test_"+e_Image)
  end
  
end

cuts = Template_Resize.new(In_Image)
cuts.XY_Pos(X_Size,Y_Size)
cuts.Image_Props
#cuts.Image_Cuts
cuts.Image_Write
