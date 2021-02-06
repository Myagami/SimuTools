#!/usr/bin/env ruby

#debug
require 'pp'
require '/home/karen/Tools/SimuTools/Dat_Inspection/dat_inspection'
#use vars
debug = ARGV[1] ? true : false
#di = DatInspection.new(true)
di = DatInspection.new(debug)
di.LoadFile(ARGV[0])
di.Inspection
pp di.ExportLog

