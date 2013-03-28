####################################################################################################
. $PROFILE/${1}_profile.sh
####################################################################################################
cd ${BEHAV_dir}
###################################################################################################
# Written by Kyle Almryde 1/21/2012
# Thanks to Tom Hicks and Dianne Patterson for suggestions and troubleshooting.
# Buttons 1 and 2 are equivalent (and what the subject should press if s/he thinks the test is a 
# nonword). Buttons 3 and 4 are equivalent (and what the subject should press if s/he thinks the 
# test is a true word)
####################################################################################################
echo "-------------------------------- eprime.sh ----------------------------------"
echo "This massages text from an eprime file generated by the ${1} imaging experiment"
echo "-------------------------------- ${subrun} --------------------------------"
echo ""
####################################################################################################
# The eprime on the new scanner PC produces text files in UTF16.  This breaks everything. iconv can 
# do the conversion back to a standard text format that sed likes.
####################################################################################################
echo "iconv -f UTF-16 -t ISO-8859-1 ${subj}-${run}.txt > iconv.iso.${subrun}.txt"
#iconv -f UTF-16 -t ISO-8859-1 ${subj}-${run}.txt > iconv.iso.${subrun}.txt
####################################################################################################
# This is crucial, as the windows line returns broke paste in horrible ways
# The dos2unix tool is part of the fink distribution, but you have to go get it.
# Thanks Tom ; )
####################################################################################################
echo "dos2unix iconv.iso.${subrun}.txt"
#dos2unix iconv.iso.${subrun}.txt
####################################################################################################
# To make sure we never encounter this horrible problem ever again, we are going to replace the
# Original file all together, and mv the iconv.iso.file-name to the original name (so none are the
# wiser ;-)
####################################################################################################
echo "rm ${subj}-${run}.txt; mv iconv.iso.${subrun}.txt ${subj}-${run}.txt"
#rm ${subj}-${run}.txt; mv iconv.iso.${subrun}.txt ${subj}-${run}.txt
####################################################################################################
# Extract just the rows of interest. By using the -e the sed commands are all executed together,
# so we retain the line ordering of the file
####################################################################################################

cat ${subj}-${run}.txt | sed -n -e '/Target:/p' -e '/WordType:/p' \
	-e '/SpeakerGender:/p' -e '/SlideTarget.RT:/p' -e '/SlideTarget.RESP:/p' \
	-e '/CorrectAnswer:/p' | tr -d '\t' 	> tmp.${subrun}
####################################################################################################
# Create the Report file and echo the column title into it. Run3 does not have a SpeakerGender
# component, so do not add that column for that run
####################################################################################################

if [ "${run}" = "TP1" ]; then
	echo "Timing SoundFile WordType RT CESP RESP ACC" > header.${subrun}
else
	echo "Timing SoundFile WordType SpeakerGender RT CRESP RESP ACC" \
													> header.${subrun}
fi
####################################################################################################
# Add a clean list of the sound files, swap _ for spaces in wav file names
# Get lines containing RT (or Target.RESP or CRESP) and save the 2nd field
####################################################################################################

cat tmp.${subrun} | grep RT | awk '{print $2}' >> rt.${subrun}
cat tmp.${subrun} | grep SpeakerGender | awk '{print $2}' >> speakergender.${subrun}
cat tmp.${subrun} | sed -n 's/Target: //p' | awk '{print $1}' >> soundfile.${subrun}
cat tmp.resp.${subrun} | sed 's/$/ 0/' | awk '{print $1}' >> resp.${subrun}
cat tmp.${subrun} | grep CorrectAnswer | awk '{print $2}' >> cresp.${subrun}


cat tmp.${subrun} | grep WordType | awk '{print $2}' >> tmp.wordtype.${subrun}

cat tmp.${subrun} | grep SlideTarget.RESP | awk '{print $2}' >> tmp.resp.${subrun}

####################################################################################################
# Replace single letter identifiers with whole words in order to make sorting that much easier 
# later on.
####################################################################################################

if [ "${run}" = "TP1" ]; then
	cat tmp.wordtype.${subrun} | sed -e "s/N/New/g" -e "s/O/Old/g" \
		>> wordtype.${subrun}
else 
	cat tmp.wordtype.${subrun} | sed -e "s/A/Animal/g" -e "s/F/Food/g" \
		>> wordtype.${subrun}
fi

rm tmp.wordtype.${subrun}

################################################################################
# Some of the subject files had the target-response switched between the 
# targets, resulting in a higher than normal rate of errors at no fault of the 
# subjects (or is it...). This block of code corrects that problem. Here is a 
# step by step explainaition of what the code is doing
#
#  First: Using paste, combine the speakergender.file and the cresp.file,
#         creating the voice.cresp.file
# Second: Using SED change the correct response for Male from 2 to 3, and the
#         correct response for Female from 3 to 2, print those changes to a file 
#         named voice.cresp.fix.file
# Third:  Using CAT and AWK, print $1 (Speakergender) to speakergender.tmp.file
#		  then print $2 (CRESP) to cresp.tmp.file
#Fourth: Move speakergender.tmp.file to speakergender.file, overwriting the 
#        original. The same is done for the cresp.tmp.file ==> cresp.file
################################################################################


if [ "${run}" = "SP2" ]; then 

	if [ "$subj" = "TS001" -o  "$subj" = "TS002" -o  "$subj" = "TS014" ];then

		echo "nothing to see here"

	else

		paste -d" " speakergender.${subrun} cresp.${subrun} \
											>> tmp.voice.cresp.${subrun}
		cat tmp.voice.cresp.${subrun} | sed -e 's/male 2/male 3/g' \
						-e 's/female 3/female 2/g' >> voice.cresp.fix.${subrun}
		cat voice.cresp.fix.${subrun} | awk '{print $1}' \
											>> tmp.speakergender.${subrun}
		cat voice.cresp.fix.${subrun} | awk '{print $2}' >> tmp.cresp.${subrun}
		mv tmp.speakergender.${subrun} speakergender.${subrun}
		mv tmp.cresp.${subrun} cresp.${subrun}

	fi

elif [ "${run}" = "TP2" ]; then

	if [ "$subj" = "TS001" -o "$subj" = "TS002" -o "$subj" = "TS005" \
		-o "$subj" = "TS006" -o "$subj" = "TS007" -o "$subj" = "TS014" ];then

		echo "nothing to see here"
	else
		paste -d" " speakergender.${subrun} cresp.${subrun} \
													>> tmp.voice.cresp.${subrun}
		cat tmp.voice.cresp.${subrun} | sed -e 's/male 2/male 3/g' \
						-e 's/female 3/female 2/g' >> voice.cresp.fix.${subrun}
		cat voice.cresp.fix.${subrun} | awk '{print $1}' \
												>> tmp.speakergender.${subrun}
		cat voice.cresp.fix.${subrun} | awk '{print $2}' >> tmp.cresp.${subrun}
		mv tmp.speakergender.${subrun} speakergender.${subrun}
		mv tmp.cresp.${subrun} cresp.${subrun}
	fi
fi
################################################################################
# This section will create the ACC.Report
#  First: Using Paste, combine the resp.file and the cresp.file, creating the resp.cresp.file. 
# Second: Compare the contents of field $1 to $3, if they are equal, print a value of 1 in 
# 		  field $3 if they are different, print a value of 0 in filed $3, name the file acc.file
################################################################################

paste -d" " resp.${subrun} cresp.${subrun} >> tmp.resp.cresp.${subrun}

cat tmp.resp.cresp.${subrun} | awk \
	'{ if( $1==$2){ print $3=1}; if($1 != $2){print $3=0}}' >> acc.${subrun}

if [ "${run}" = "SP1" ]; then

	echo "WordType RESP CRESP ACC" >> acc.header.${subrun}
	
	paste -d" " wordtype.${subrun} resp.${subrun} cresp.${subrun} acc.${subrun}\
													>> tmp.acc.header.${subrun}
									
	grep -E 'Animal|Food' tmp.acc.header.${subrun} >> acc.header.${subrun}

elif [ "${run}" = "TP1" ]; then

	echo "WordType RESP CRESP ACC" >> acc.header.${subrun}
	
	paste -d" " wordtype.${subrun} resp.${subrun} cresp.${subrun} \
									acc.${subrun} >> tmp.acc.header.${subrun}
									
	grep -E 'Old|New' tmp.acc.header.${subrun} >> acc.header.${subrun}
	
else
	echo "SpeakerGender RESP CRESP ACC" >> acc.header.${subrun}
	
	paste -d" " speakergender.${subrun} resp.${subrun} cresp.${subrun} \
									acc.${subrun} >> tmp.acc.header.${subrun}
									
	grep male tmp.acc.header.${subrun} >> acc.header.${subrun}
fi

	cat acc.header.${subrun} | awk -v OFS='\t' '$1=$1' \
												>> ACC.Report.${subrun}.txt
################################################################################
# Paste the fields I want in contiguous space separated columns, taking into
# account the difference in header info for run TP1. Then utilize grep to remove 
#the null conditions from the report
################################################################################

if [ "${run}" = "TP1" ]; then
	paste -d" " etc/timing.txt soundfile.${subrun} wordtype.${subrun} \
			rt.${subrun} cresp.${subrun} resp.${subrun} acc.${subrun} \
												>> tmp.report.${subrun}

	grep -E 'Old|New' tmp.report.${subrun} >> tmp.report2.${subrun}

else

	paste -d" " etc/timing.txt soundfile.${subrun} wordtype.${subrun} \
	speakergender.${subrun} rt.${subrun} cresp.${subrun} resp.${subrun} \
									acc.${subrun} >> tmp.report.${subrun}
		
	grep male tmp.report.${subrun} >> tmp.report2.${subrun}
	
fi	
################################################################################
# print the contents of the tmp.report2.file to the header.file, then change the 
# delimiter from spaces to tabs to produce the Report.file
################################################################################

cat tmp.report2.${subrun} >> header.${subrun}
cat header.${subrun} | awk -v OFS='\t' '$1=$1' >> Report.${subrun}.txt
################################################################################
# Remove the tmporary files used to construct the final report, and move the original files
# to the etc directory
################################################################################

rm  tmp.${subrun} header.${subrun} soundfile.${subrun} tmp.wordtype.${subrun}\
	rt.${subrun} resp.${subrun} tmp.resp.${subrun} cresp.${subrun} \
	speakergender.${subrun} wordtype.${subrun} tmp.resp.cresp.${subrun} \
	tmp.acc.header.${subrun} acc.header.${subrun} acc.${subrun} \
	tmp.voice.cresp.${subrun} voice.cresp.fix.${subrun} tmp.report2.${subrun} \
	tmp.report.${subrun}


mv  ACC.Report.${subrun}.txt Responses/
####################################################################################################
echo "-------------------------------- Examination ----------------------------------"
echo "This examines the results from text originating in an eprime file generated by "
echo "the ${1} imaging experiment. It will match resposes, average results, then link"
echo "various items from the Test-Phase to the corresponding Study-Phase"
echo "-------------------------------- ${subrun} --------------------------------"
echo ""
################################################################################
# Pass the contents of Report.${subrun}.txt to awk
################################################################################
#cat Report.${subrun}.txt | 
# d' = z(HITS) - z(FAlarms) 



echo "

This control structure will extract the 

if run == SP1; then
	cat Report.subrun.txt | grep -E /Animal Female / >> SP1.Af.response
	cat Report.subrun.txt | grep -E /Animal male / >> SP1.Am.response
	cat Report.subrun.txt | grep -E /Food Female / >> SP1.Ff.response
	cat Report.subrun.txt | grep -E /Food male / >> SP1.Fm.response

if run == SP2; then
	cat Report.subrun.txt | grep -E /Animal Female / >> SP2.Af.response
	cat Report.subrun.txt | grep -E /Animal male / >> SP2.Am.response
	cat Report.subrun.txt | grep -E /Food Female / >> SP2.Ff.response
	cat Report.subrun.txt | grep -E /Food male / >> SP2.Fm.response

if run == TP1; then 
	cat Report.subrun.txt | grep -E /Old something 1/ >> TP1.old.hits
	cat Report.subrun.txt | grep -E /Old something 0/ >> TP1.old.falseAlarms	
	
	cat Report.subrun.txt | grep -E /NEW something 1/ >>TP1.new.correctReject
	cat Report.subrun.txt | grep -E /NEW something 1/ >>TP1.new.miss
fi

if run == TP2; then
	cat Report.subrun.txt | grep -E /Old something 1/ >> TP2.old.hits
	cat Report.subrun.txt | grep -E /Old something 0/ >> TP2.old.falseAlarms	
	
	cat Report.subrun.txt | grep -E /NEW something 1/ >>TP2.new.correctReject
	cat Report.subrun.txt | grep -E /NEW something 1/ >>TP2.new.miss

"


