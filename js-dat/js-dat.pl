#!/usr/bin/env perl

use utf8 ;
use strict ;
use warnings ;
use JSON ;
use File::Slurp;
use Data::Dumper ; 

#use variable
my $IMPORT_JSON_FN ;
my $EXPORT_DAT ;
my $IMPORT_JSON_CON ;
my $Processing_JSON ; 

#readfile
$IMPORT_JSON_FN = $ARGV[0] ;
$IMPORT_JSON_CON = File::Slurp::read_file($IMPORT_JSON_FN);
$Processing_JSON = JSON::decode_json($IMPORT_JSON_CON) ; 
print Dumper($Processing_JSON) ;
#print %Processing_JSON ;
#print $Processing_JSON->{Train1} ; 
