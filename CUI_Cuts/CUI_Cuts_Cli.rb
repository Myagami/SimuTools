#!/usr/bin/env ruby

require './CUI_Cuts'

cuts = Cui_Cuts.new(In_Image)
cuts.XY_Pos(X_Size,Y_Size)
cuts.Image_Props
cuts.Image_Cuts
cuts.Image_Write
