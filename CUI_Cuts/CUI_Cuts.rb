#!/usr/bin/env ruby

#Argvars
In_Image = ARGV[0] 
X_Size = ARGV[1] 
Y_Size  = ARGV[2] 

#private vars

#require and new instance
require 'rmagick'
require 'inifile'

#crop
class Cui_Cuts
  def initialize(in_image) #start
    @In_Image = in_image
    @Out_Image = In_Image.sub(/.png/,'_src.png')
    @image = Magick::ImageList.new(In_Image)
    @image_Crops = Array.new(Y_Size.to_i).map{Array.new(X_Size.to_i)}

    #@Out_Image = 
  end

  def XY_Pos(x_size,y_size)
    @X_Size = x_size
    @Y_Size = y_size    
  end

  def Image_Props
    print "Export: "
    puts @Out_Image

    #props
    print "Width:"
    puts @image.columns
    print "Height:"
    puts @image.rows
    print "X:"
    puts @X_Size
    print "Y:"
    puts @Y_Size

    @Crop_X = (@X_Size.to_i - 1) * 32
    @Crop_Y = (@Crop_X / 2) + 16
  end

  def Image_Cuts #Image Cutter
    ct_x = 1
    #y
    for ct_y , y_pos in 1..@Y_Size.to_i do
      print "X_Offset: "
      puts (ct_x - 1) * 16
      print "Y_Offset: "
      puts (ct_y - 1) * 16
      
      x_pos = @Crop_X.to_i + (ct_x.to_i - 1) * 16
      y_pos = @Crop_Y.to_i - (ct_y.to_i - 1) * 16

      print "Y_pos: "
      puts y_pos
      print "X_pos: "
      puts x_pos

      print "----\n"
      #x
      for ct_x in 1..X_Size.to_i do
        print "X: " 
        puts ct_x.to_i
        
        print "Y_pos: "
        puts y_pos 
        print "X_pos: "
        puts x_pos 

        #override
        c_Image = @image.crop(Magick::SouthEastGravity,x_pos.to_i,y_pos.to_i,64,64,true){
          self.background_color='red'
        }

        #masking
        #common
        mask = Magick::Image.new(64,64){self.background_color='none'}
        mask_Path = Magick::Draw.new()
        mask_Path.stroke_antialias(false)
        mask_Path.clip_rule("evenodd") 
        mask_Path.polygon(0,49,
                          28,63,
                          29,63,
                          0,63)
        mask_Path.polygon(63,49,
                          35,63,
                          34,63,
                          63,63)
        #center
        if ct_y == 1 && ct_x != 1 then
          print "1st line\n"
          mask_Path.polygon(0,0,
                            0,47,
                            30,32,
                            31,32,
                            31,0)
        elsif ct_y >= 2 && ct_x == 1 then
          mask_Path.polygon(32,0,
                            32,32,
                            33,32,
                            63,47,
                            63,0)
        elsif ct_y >= 2 && ct_x != 1 then
          mask_Path.polygon(0,0,
                            0,47,
                            30,32,
                            31,32,
                            31,0)
          mask_Path.polygon(32,0,
                            32,32,
                            33,32,
                            63,47,
                            63,0)
          print "center Y\n" 
        end
        mask_Path.draw(mask)
        

        #bottom
        @image_Crops[ct_y.to_i - 1][ct_x.to_i - 1] = mask.composite(c_Image,0,0,Magick::SrcOutCompositeOp)
        x_pos = x_pos - 32
        y_pos = y_pos - 16
      end
      print "---------\n"
    end    
  end

  def Image_Write
    exb = Magick::Image.new(X_Size.to_i*64,Y_Size.to_i*64){
       self.background_color="#E7FFFF"
    }

    ct_y = 0
    ct_x = 0
    expo = 0 
    @image_Crops.each do |y_img|
      y_img.each do |x_img|
        exb.composite!(x_img,ct_x * 64,ct_y * 64,Magick::OverCompositeOp)
        ct_x = ct_x + 1
      end
      ct_x = 0 
      print "\n" 
      ct_y = ct_y + 1
    end
    
    #Export
    exb.write(@Out_Image)
  end
  
end

