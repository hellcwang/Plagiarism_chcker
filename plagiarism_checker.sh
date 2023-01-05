#!/bin/bash
help_msg (){
	echo "-h help message"
	echo "-e extension name (default c, h, cpp) like \"java py\""
	echo "-d difference ratio (default 90)"
	echo "Usage: ./plagiarism_checker [-e file extension][dir]"
}


# output coloring
red='\033[0;31m'
nc='\033[0m'
ext=$'c\ncpp\nh\nhpp'
#ext=$(echo "$ext")
cur="$PWD"
dif=90

# support filenames with spaces:
#IFS=$(echo -en "\n")
IFS=$'\n'

while [ $# -gt 0 ];do
	case $1 in 
	-e | --extension)
		ext="$2"
		shift
		shift
		;;
	-d | --diff)
		dif="$2"
		shift
		shift
		;;

	-h | --help)
		help_msg
		shift
		;;

	-* | --*)
		help_msg
		shift
		;;
	*)
		POSITIONAL_ARGS+=("$1")
		shift
		;;
	esac
done

# Restore the positional args
set -- "${POSITIONAL_ARGS[@]}"

# Replace ' ' to '\n'
ext=$(echo $ext | sed "s/ /\n/g")

	
		
cd "$1" || echo "$1 is not directory" 

working_dir="$PWD"
working_dir_name=$(echo $working_dir | sed 's|.*/||')
all_files="$working_dir/../$working_dir_name-filelist.txt"
remaining_files="$working_dir/../$working_dir_name-remaining.txt"

# initialize the log file
> $all_files
> $remaining_files

# get information about files:
for ex in ${ext[@]}; do
	find -type f -print0 | xargs -0 stat -c "%s %n" | grep -v "/\." | \
		grep "\.${ex}$" | sort -nr  >> $all_files
done


cp $all_files $remaining_files

while read string; do
        fileA=$(echo $string | sed 's/.[^.]*\./\./')
	extA=${fileA##*.}
        tail -n +2 "$remaining_files" > $remaining_files.temp
        mv $remaining_files.temp $remaining_files

        echo Comparing $fileA with other files...
        while read string; do

		fileB=$(echo $string | sed 's/.[^.]*\./\./')
		bash $cur/compare.sh "${fileA}" "${extA}" "${fileB}" "$1" $dif &
		 
        done < "$remaining_files"
	wait 
        echo " "
done < "$all_files"

if [ -e $all_files ]
then
        rm "$all_files"
fi
if [ -e $remaining_files ]
then
        rm "$remaining_files"
fi
