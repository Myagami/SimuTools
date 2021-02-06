#!/usr/bin/env ruby
In_Image = ARGV[0] 
X_Size = ARGV[1] 
Y_Size  = ARGV[2] 

require_relative 'CUI_Cuts'

cuts = CUI_Cuts.new(In_Image)
cuts.XY_Pos(X_Size,Y_Size)
cuts.Image_Props
cuts.Image_Cuts
cuts.Image_Write
