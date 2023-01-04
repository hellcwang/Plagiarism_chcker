#!/bin/bash
red='\033[0;31m'
nc='\033[0m'


# Need three parameters
# $1 is fileA, $2 is extA, $3 is fileB, $4 is the target 
if [[ $# != 4 ]]
then
	exit 1
fi
#echo "$1 $2 $3 $4"
cd "$4"
fileA="$1"
extA="$2"
fileB=$(echo "$3" ) 
extB=${fileB##*.}
if [[ $extA != $extB ]]
then
	exit 0
fi
#sed '/^$/d' $fileB > tempB
#sed '/^$/d' $fileA > tempA
A_len=$(cat $fileA |wc -l )
B_len=$(cat $fileB |wc -l )


differences=$(sdiff -BWZbdEi -s $fileA $fileB | wc -l)
common=$(expr $A_len - $differences)

percentage=$(echo "100 * $common / $B_len" | bc)
if [[ $percentage -gt 90 ]]; then
	echo -e "$red  $percentage% duplication in" \
		"$(echo $fileB | sed 's|\./||')" \
		"$nc"
fi
exit 0

