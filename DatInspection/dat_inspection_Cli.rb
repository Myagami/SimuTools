#!/usr/bin/env ruby

#debug
require 'pp'
require 'DatInspection'
#use vars
debug = ARGV[1] ? true : false
#di = DatInspection.new(true)
di = DatInspection.new(debug)
di.LoadFile(ARGV[0])
di.Inspection
pp di.ExportLog

