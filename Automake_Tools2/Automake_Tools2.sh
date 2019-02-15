#!/usr/bin/zsh
#vals
#--path--
PAK='./pak/' ;
DAT='./' ;
PNG='./' ;

#--params--
#MAKE='makeobj_51' ;
MAKE='makeobj_60-2_x64' ; 
FLAG=0 ;
N_PAIR=0 ;

C_File="" ;
C_File_2="" ;
W_File="" ;

#--File states--
SRC='_src' ;
TIS_FN=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 30 | head -n 1 | sort | uniq`;
TIS_STAMP=`date +"%y%m%d%H%M.%S"`
TIS_PATH=""
CP_PATH="/home/honoka/simutrans/pak.nippon.tests/"

#functions
#Timestamp file create
function TIS_File_Create(){ #timestamp memory file create
    TIS_PATH="/tmp/AMT_$TIS_FN" ;
    touch -t $TIS_STAMP $TIS_PATH ;
    echo $TIS_PATH;

}


TIS_File_Create #timestamp

#Working Mode
while getopts "r:s:m:" ropt; do
	case "$ropt" in
		r)
			MODE="Rot" ;
			DIR=$OPTARG ;;
		s)
			MODE="Std"
			DIR=$OPTARG ;;
		m)
			MODE="Make";
			DIR=$OPTARG ;;
	esac
done

#Sub Options

# Working Directory
PWS=(`pwd | tr -s '/' ' '`) ;
BASE_PWD=$PWS[${#PWS[@]}]
echo "Base Dirctory :"$BASE_PWD ;
echo "Makeobj :"$MAKE ;

#Mode Switch

inotifywait -m -e close_write --format %w,%f -r $DIR|
	#inotifywait -m -e close_write --format %w%f -r $DIR|
	while read files;do

		#update file check
		#if [[ ${files} =~ _src.png ]] ; then || [[ ${files} =~ png ]] || [[ ${files} =~ dat ]] ; then
		if [[ !${files} =~ _src.png ]]; then #cutted image file
			#non
		elif [[ ${files} =~ png ]] || [[ ${files} =~ dat ]] ; then
			#file splits path
			f_path=(`echo ${files} | tr -s ',' ' '`) ; #parce file path

			#Opration Mode
			if test "$MODE" = "Rot" ;  then # Router Mode
				#WORK_DIR=`echo $f_path[1] | sed -e "s/\(.\/[a-zA-Z_-]\{1,\}\/\).*/\1/"`"pak/" #pak export path
				WORK_DIR=$DIR"/pak/"
			elif test "$MODE" = "Std" ; then # Standalone Mode
				#WORK_DIR=$DIR"pak/"
				echo "Mode: Standalone"
			elif test "$MODE" = "Make" ; then # Makefile using Mode
				echo "Mode: makefile"
			fi
			
			#pair from png
			if [[ ${files} =~ .png ]]; then
				DAT=`echo $files | sed -e "s/,//" | sed -e "s/png/dat/"`
				Worker=`echo $files | sed -e "s/,//" | sed -e "s/png/sh/"`
				PNG=`echo $files | sed -e "s/,//"`
				#Worker check
				if [[ -e $Worker ]]; then
				    $Worker $f_path[1]
				fi
			elif [[ ${files} =~ .dat ]]; then
				echo "Trade:Direct Pak"
				DAT = $f_path[1]
			fi

			#run makeobj
			$MAKE pak $WORK_DIR $DAT
			`cp $WORK_DIR*.pak ~/simutrans/pak.nippon.tests/`

			echo `date +"%y/%m/%d %T"`" : "$files ;
			echo "WorkDir: "$WORK_DIR
			echo "DAT: "$DAT
			echo "PATH: "${files}
			echo "Worker: "$Worker
			echo "--------------------"
		fi
	done

