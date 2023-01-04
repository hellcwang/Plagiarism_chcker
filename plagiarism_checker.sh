#!/bin/bash


# output coloring
red='\033[0;31m'
nc='\033[0m'
ext=$'c\ncpp\nh\nhpp'
#ext=$(echo "$ext")
cur="$PWD"

# support filenames with spaces:
#IFS=$(echo -en "\n")
IFS=$'\n'

if [ $# -gt 0 ] 
then
        cd "$1" || echo "$1 is not directory" 
else
        echo -e "Usage:   ./plagarism [dir] "
fi

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
		bash $cur/compare.sh "$fileA" "$extA" "$fileB" "$1" &
		 
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
