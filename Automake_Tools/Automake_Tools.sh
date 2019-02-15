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
#--- functions ---
#---- TimeStanp ----
function TIS_File_Create(){ #timestamp memory file create
    TIS_PATH="/tmp/AMT_$TIS_FN" ;
    touch -t $TIS_STAMP $TIS_PATH ;
    echo $TIS_PATH;

}

function TIS_File_Update(){ #timestamp memory file update
    TIS_STAMP=`date +"%y%m%d%H%M.%S"`
    echo $TIS_PATH;
    touch -t $TIS_STAMP $TIS_PATH ;
}

#---- locking ----
function PairFileCheck() { #check dat / png pair
    C_File_2=`echo $files | sed -e "s/,//"` ;
    if [[ $1 == "src_d" ]] ; then
	if [[ -e $C_File ]] && [[ -e $C_File_2 ]] ; then
	    echo $C_File_2 ;
	else
	    false ;
	fi 
    elif [[ $1 == "src_i" ]] ; then
	if [[ -e $C_File ]] && [[ -e $C_File_2 ]] ; then
	    echo $C_File;
	else
	    false ;
	fi 
    elif [[ $1 == "stand_d" ]] ; then
	if [[ -e $C_File ]] && [[ -e $C_File_2 ]] ; then
	    echo $C_File_2 ;
	else
	    false ;
	fi
    elif [[ $1 == "stand_i" ]] ; then
	if [[ -e $C_File ]] && [[ -e $C_File_2 ]] ; then
	    echo $C_File ;
	else?
	    false ;
	fi
    elif [[ $1 == "stand_g" ]] ; then
	if [[ -e $C_File ]] && [[ -e $C_File_2 ]] ; then
	    echo $C_File ;
	else
	    false ;
	fi
    fi
}

function FlagModifyFile() { #file check flag
    if [[ ${files} =~ pak ]] || [[ ${files} =~ xcf ]] || [[ ${files} =~ tcp ]] || [[ ${files} =~ tmp ]] || [[ ${files} =~ zip ]] || [[ ! -n "$DIR" ]] || [[ ${files} =~ git ]] || [[ ${files} =~ tab ]] || [[ ${files} =~ locking ]] || [[ ${files} =~ makefile ]] || [[ ${files} =~ md ]]  || [[ ${files} =~ html ]] then
	echo 0 ;
    else
	echo 1 ;
    fi
}

function GetTargetFile () { #make target check
    if [ ! -e $f_path[1]"locking" ] ;then
	if [[ ${files} =~ png ]]; then #src file
	    C_File=`echo $files | sed -e "s/,//" -e "s/.png/.dat/"` ;
	    #echo $C_File ;
	    echo `PairFileCheck stand_i` ;
	elif [[ ${files} =~ goods ]]; then #goods dat file
	    C_File=`echo $files | sed -e "s/,//" -e "s/_src.png/.dat/"` ;
	    echo `PairFileCheck stand_g` ;
	elif [[ ${files} =~ dat ]]; then #dat file
	    C_File=`echo $files | sed -e "s/,//" -e "s/.dat/.png/"` ;
	    echo `PairFileCheck stand_d` ;
	    #echo $C_File ;
	fi
    else # srcファイル / dat更新のみpak化
	#if [[ ${files} =~ _src ]] || [[ ${files} =~ dat ]]; then
	if [[ ${files} =~ _src ]]; then #src file
	    C_File=`echo $files | sed -e "s/,//" -e "s/_src.png/.dat/"` ;
	    echo `PairFileCheck src_i`; 
	elif [[ ${files} =~ dat ]]; then #dat file
	    C_File=`echo $files | sed -e "s/,//"` ;
	    echo `PairFileCheck src_d` ;
	fi
    fi
    
}
#--- file ---
function Pak_NewCopy(){
    echo "pak:"$PAK;
    echo "tfi:"$TIS_PATH ;
    find $PAK -type f -newer $TIS_PATH -exec cp {} $CP_PATH \;
    
}


#options
while getopts "c:d:p:k:r:s:m:n:-:" opt; do
    case "$opt" in
        -)
            case "${OPTARG}" in
                HL) #High and Low Support
		    MAKE='makeobj_55-3'
		    echo "High and Low";;
		
		dat) #dat
		    shift `expr $OPTIND - 1` ;
		    DAT=$1;
		    echo "dat $1 ";;		
		png) #png
		    shift `expr $OPTIND - 1` 
		    PNG=$1;
		    echo "png $1 ";;
		pak) #pak
		    shift `expr $OPTIND - 1`
		    PAK=$1;
		    echo "pak $1 ";;
		dir) #dir
		    shift `expr $OPTIND - 1` ;
		    DIR=$1;;
		std) #dir
		    shift `expr $OPTIND - 1` ;
		    STD=$1;;

		src) #dir
		    shift `expr $OPTIND - 1` ;
		    SRC=$1;;
		
            esac 
           ;;
	c) #コピー先を指定(def:simutrans/pak.nippon.tests)
	    CP_PATH=$OPTARG;;
        d) #dat / 監視datファイルを指定
	    DAT=$OPTARG;;
        p) #png / 
	    PNG=$OPTARG;;
	k) #pak / 生成pak名を指定する
	    PAK=$OPTARG;;$
	g) #特定のディレクトリを監視しない
	    IGN=$OPTARG;;
	s) #単独動作 / 配下ディレクトリ内のpakへ出力
	    STD=$OPTARG ;;
	m) #makefile
	    DIR=$OPTARG ;
	    MAKE="make" ;;

	d) #pakを出力するディレクトリ指定
		DIR=$OPTARG ;
	    PAK='./pak/' ;;
	
	r) #rotate / 指定ディレクトリ以下を監視する
	    DIR=$OPTARG
	    PAK='./pak/' ;
    esac
done
#Working Directory
PWS=(`pwd | tr -s '/' ' '`) ;
BASE_PWD=$PWS[${#PWS[@]}]
echo "Base Dirctory:"$BASE_PWD ;
#Use makeobj Version
echo "Makeobj:"$MAKE ;
#Create Timestamp files
TIS_File_Create
#Action Filters
if [ $MAKE = "make" ]; then #makefile target mode

    echo "Dir:"$DIR ;
    echo "Monitor Start target Directory $DIR for makefile" ;
    echo "----------------------------"
    PAK=`echo $PAK | sed -e "s/.\///"` ;
    inotifywait -m -e close_write --format %w,%f -r $DIR|
	while read files;do
	    f_path=(`echo ${files} | tr -s ',' ' '`) ;
	    WORK_DIR=`echo $f_path[1] | sed -e "s/\(.\/[a-zA-Z_-]\{1,\}\/\).*/\1/"`"pak/"
	    TARGET=`echo $f_path[2] | sed -e "s/.png\|.dat/.pak/"` ;
	    FLAG=`FlagModifyFile` ;
	    if [[ $FLAG == 1 ]]; then
		if [[ ${files} =~ dat ]]; then #dat file
		    TARGET=`echo $TARGET | sed -e "s/.mh-cs-building_ex/_mod_/" -e "s/.pak/_ex.pak/" ` ;
		    Pak_NewCopy ;
		    TIS_File_Update ;
		fi
		#building.mh-cs-building_ex1.pak
		#building_mod_1_ex.pak
		make $PAK$TARGET ;
		#echo $PAK$TARGET ;
		echo "----------------------------" ;
	    fi
	done
elif [ -n "$STD" ]; then #standalone mode
    DIR=$STD ;
    TIS_File_Create ;
    echo "Dir:"$STD ;
    echo "Monitor Start target Directory $DIR for Standalone" ;
    echo "----------------------------"
    inotifywait -m -e close_write --format %w,%f -r $STD|
	while read files;do
	    f_path=(`echo ${files} | tr -s ',' ' '`) ;
	    WORK_DIR=`echo $f_path[1] | sed -e "s/\(.\/[a-zA-Z_-]\{1,\}\/\).*/\1/"`"pak/"
	    FLAG=`FlagModifyFile` ;
	    #file type flag
	     if [[ $FLAG == 1 ]]; then
	     	 #echo "Works" ;
	     	 TARGET=`GetTargetFile`
	     	 if [[ -n $TARGET ]]; then
		     PAK=$f_path[1]"pak/" ;
		     if [ -e $PAK ] ;then #Working Dir check
	     		 $MAKE pak $PAK $TARGET
			 echo "-------------" ;
			 Pak_NewCopy ;
			 TIS_File_Update ;
		     else #not found
			 f_path[1]=`echo $f_path[1] | xargs dirname` ;#mother dir

			 PAK=$f_path[1]"/pak/" ;
			 if [ -e $PAK ];then
	     		     $MAKE pak $PAK $TARGET
			     Pak_NewCopy ;
			     TIS_File_Update ;
			 else
			     echo "Not Found Working Directory!"
			 fi
			 #echo $PAK ;

		     fi
		     
	     	 else
	     	     echo "outs" ;
	     	 fi
		 
		 #touch $WORK_DIR"test.txt"
	     fi
	    
	    # if [[ ${files} =~ pak ]] || [[ ${files} =~ xcf ]] || [[ ${files} =~ tcp ]] || [[ ${files} =~ tmp ]] || [[ ${files} =~ zip ]] || [[ ! -n "$STD" ]] || [[ ${files} =~ git ]] || [[ ${files} =~ tab ]] || [[ ${files} =~ locking ]]; then
	    # 	#echo $files ;
	    # 	#echo "No Working Diretory." ;

	    # else
	    # 	TARGET=`GetTargetFile`
	    # 	echo $TARGET  ;
	    # if
	done
elif [ -n "$DIR" ]; then
    echo "Dir:"$DIR ;
    echo "Monitor Start target Directory $DIR" ;
    WORK_DIR=$DIR"pak/" ;
    inotifywait -m -e close_write --format %w,%f -r $DIR|
    #inotifywait -m -e close_write --format %w%f -r $DIR|
	while read files;do
	    #
	    f_path=(`echo ${files} | tr -s ',' ' '`) ;
	    FLAG=`FlagModifyFile` ;

	    #file type flag
	    #if [[ $N_PAIR == 1]] ;then
	    #else

	    if [[ $FLAG == 1 ]]; then
		#echo "Works" ;
		TARGET=`GetTargetFile`
		if [[ -n $TARGET ]]; then
		    $MAKE pak $PAK $TARGET
		    Pak_NewCopy ;
		    TIS_File_Update ;
		else
		    echo "out" ;
		fi
		#$MAKE pak $DIR $TARGET
		#touch $WORK_DIR"test_2.txt"
		echo "-------------------" ;
	    fi
	done
else
    echo "DAT:"$DAT ; 
    echo "PNG:"$PNG ;
    echo "PAK":$PAK ;
    echo "Monitor Start target file Dat:$DAT png:$PNG" ;
    inotifywait -m -e close_write,create,delete --format %w $DAT $PNG|
	while read files;do
	    echo `date +"%y/%m/%d %T"`" : "$files ;
	    echo `date +"%y/%m/%d %T"`" : "$files >> log.txt
	    echo "--------------------------------" ;
	    echo "Makeobj Log" ;
	    echo "--------------------------------" ;
	    makeobj_51 pak $PAK $DAT ;
	    #cp $PAK ~/simutrans/addons/pak.dev
	    `cp ./pak/*.pak ~/simutrans/addons/pak.nippon.tests`
	    #
	    #date +"%y/%m/%d %T";
	done
fi

trap 'rm -rf $TIS_PATH' 1 2 3 15
