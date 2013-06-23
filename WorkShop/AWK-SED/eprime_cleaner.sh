#!/bin/sh
# Written by Dianne Patterson 5/11/2011
# Thanks to Tom Hicks and Kyle Almryde for suggestions and troubleshooting
# Buttons 1 and 2 are equivalent (and what the subject should press if s/he thinks the test is a nonword)
# Buttons 3 and 4 are equivalent (and what the subject should press if s/he thinks the test is a true word)


if [ $# -lt 1 ]
then
    echo "Usage: $0 <input file>"
    echo "Example: $0 test.txt"
    echo "This massages text from an eprime file generated by the plante imaging experiment"
    echo ""  
    exit 1
fi

file=$1

# get the base name of the file without the txt extension
name=`basename ${file} .txt`
# This is crucial, as the windows line returns broke paste in horrible ways
# The dos2unix tool is part of the fink distribution, but you have to go get it.
# Thanks Tom ; )
dos2unix ${file}
# Extract just the rows of interest.  By using the -e the sed commands are all executed together, so we retain the line ordering of the file
cat ${file} | sed -n -e '/SoundFile/p' -e '/SlideTarget.RT:/p' -e '/SlideTarget.RESP/p' -e '/SlideTarget.CRESP/p' | tr -d '\t' > temp
# Create soundfile and echo the column title into it.
echo "soundfile RT RESP CRESP" > access_${name}.txt
# Add a clean list of the sound files, swap _ for spaces in wav file names
cat temp | sed -n -e 's/SoundFile: test items//p' | colrm 1 3 | sed 's/ /_/g'  >> soundfile
# Get lines containing RT (or Target.RESP or CRESP) and save the 2nd field
cat temp | grep RT | awk '{print $2}' >> rt
cat temp | grep Target.RESP | awk '{print $2}' >> resp
cat temp | grep CRESP | awk '{print $2}' >> cresp
# Paste the fields I want in contiguous space separated columns
paste -d" " soundfile rt resp cresp >> access_${name}.txt
rm soundfile cresp resp rt temp
