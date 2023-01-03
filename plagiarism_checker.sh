#!/bin/bash

# output coloring
red='\033[0;31m'
nc='\033[0m'
ext=$'c\ncpp\nh\nhpp'
ext=$(echo "$ext")

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
        # remove empty lines since they produce false positives
        sed '/^$/d' $fileA > tempA

        echo Comparing $fileA with other files...

        while read string; do
                fileB=$(echo $string | sed 's/.[^.]*\./\./')
		extB=${fileB##*.}
		if [[ $extA != $extB ]]
		then
			continue
		fi
                sed '/^$/d' $fileB > tempB
                A_len=$(cat tempA | wc -l)
                B_len=$(cat tempB | wc -l)

                #look at manual of sdiff for options
                differences=$(sdiff -BWZbdEi -s tempA tempB | wc -l)
                common=$(expr $A_len - $differences)

                percentage=$(echo "100 * $common / $B_len" | bc)
                if [[ $percentage -gt 90 ]]; then
                        echo -e "$red  $percentage% duplication in" \
                                        "$(echo $fileB | sed 's|\./||')" \
                                        "$nc"
                fi
        done < "$remaining_files"
        echo " "
done < "$all_files"

if [ -e tempA ]
then
        rm tempA
fi
if [ -e tempB ]
then
        rm tempB
fi
