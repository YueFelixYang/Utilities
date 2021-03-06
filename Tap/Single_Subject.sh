#!/bin/bash
#================================================================================
#	Program Name: Single_Subject.tap
#		  Author: Kyle Almryde
#			Date:
#
#	 Description: This script performs each step involved in the Single Subject
#                 analysis for the TAP study. The
#                 steps are described below:
#                           3dANOVA3
#                               3dbucket
#                               3drefit
#
#    Conventions: String variables (names) are always Lowercase
#                 Variables denoting Path names are always Uppercase
#                 Functions are denoted as _name:
#                 Script notes are formated as #===
#                 Analysis block notes are formated as a single #+++
#                 Function notes are formated as a double #+++ line
#                 Analysis Block step notes are formated as a single #---
#
#      Debugging: Each block of code has an echo at its head and foot announcing
#                 the name of the block and when that block has been completed.
#                 In this way, if an error does occur, it can be more easily
#                 tracked. In addition, an error log is created each time this
#                 script is executed to assist in locating errors and bugs.
#===============================================================================
#							  START OF MAIN
#===============================================================================

echo -n "Please enter the subject number : "
read subj

run=( SP1 SP2 TP1 TP2 )


TAP=/Volumes/Data/TAP
ICA=/Volumes/Data/TAP/ICA
STIM=/Volumes/Data/TAP/STIM





#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#							SETUP Functions
# Includes functions for setting up subject directory, unpack Pfiles,
# and renaming efiles
#
# The current list of functions under this heading :
#					setup_subjdir
#					setup_rename_anat
#					setup_spiral_unpack **incomplete**
#
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

echo "Building top level...."

mkdir -p /Volumes/Data/TAP/${subj}/{Orig,Struc,{Behav,Prep,GLM/{SP1,SP2,TP1,TP2}/IRESP}}/{SP1,SP2,TP1,TP2}

echo -n "Entering "
cd /Volumes/Data/TAP/${subj}/Orig ; pwd

echo "${subj} folder is ready to be filled"




#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#					Anatomical Image Processing
#
# The following code block performs Anatomical Image processing. Steps include:
#
# 			-Renaming anatomical e-files
#			-Reconstructing Fast-Spin-Echo (FSE)
#			-Reconstructing Spoiled-GRASS (SPGR)
#			-Co-register SPGR to FSE
#			-Warp SPGR image to Standard Space
#			-Building group anatomical image
#
# Details regarding each step and their appropriate variables follow
#
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

ANAT=/Volumes/Data/TAP/ANAT
ORIG=/Volumes/Data/TAP/${subj}/Orig
STRUC=/Volumes/Data/TAP/${subj}/Struc

	#------------------------------------------------------------------------
	#
	#	Description:  Renaming anatomical e-files
	#
	#		Purpose:  The following code segment zero padds the anatomical
	#                 e-files to ensure AFNI's to3d program will correctly
	#                 reconstruct the anatomical images.
	#
	#		  Input:  Input is an e-file taking the form e1234s5i6.
	#				  "e1234" denotes the session "s5" denotes the series,
	#				  and "i6" denotes the image number. This program is
	#				  capable of determing this information on its own.
	#				  There should be a total of 190 e-files. Depending on
	#				  the series number, there will be 26 e-files for the FSE
	#				  and 164 e-files for the SPGR
	#
	#		  Notes:  It is imperitive that the directory
	#				  /Volumes/Data/TAP/${subj}/Orig contains 190 (26 & 164)
	#				  unpacked e-files, otherwise a usage message will appear
	#				  and the program will exit.
	#
	#		 Output:  Zero padded e-files of the form e1234s5i006
	#
	#	  Variables:  j (an integer value that control the renaming),
	#				  series (denoting the image series, takes the form s#),
	#				  session (denoting the session, takes the form e####),
	#				  efile (denotes the e-file name),
	#				  fname (pre zero-padded filename),
	#
	#------------------------------------------------------------------------

	for series in s2 s7 s8; do

		j=1
		session=$(basename $(ls ${ORIG}/e* ) | grep -m 1 'e*' | cut -d s -f1)
		efile=${session}${series}

		while [ $j -le 99 ]; do

			fname="${efile}i${j}"

			if [[ ! -f $fname ]]; then
				echo "${ORIG} Missing efiles! Are you sure you unpacked them?"
				echo "efiles take the form e1234s5i6"
				echo "exiting program, make sure files have been unpacked"
				exit 0
			fi

			echo "renaming image $j"

			if [[ $j -le 9 ]]; then
				mv $fname "${efile}i00${j}"
			else
				mv $fname "${efile}i0${j}"
			fi

			((j++))

		done

	done


	#------------------------------------------------------------------------
	#
	#	Description: a
	#
	#		Purpose: a
	#
	#		  Input: a
	#
	#		 Output: a
	#
	#	  Variables: fSLICE (26) number of slices for functional and FSE images
	#				 fTHICK (5) Z-slice thickness for functional and FSE
	#				 fFOV (125.00) half the Field of View for functional and FSE
	#				 			   (240/2 = 125.00)
	#				 fZ (62.50) Size of z dimension in functional and FSE image
	#				 	 		evaluated as Slices-1 * thickness divided by 2
	#				 fZ1 (I) Inferior Z-Slice dimmension of FSE
	#				 fZ2 (S) Superior Z-Slice dimmension of FSE
	#
	#------------------------------------------------------------------------

	fZ1=I; fZ2=S; fTHICK=5; fSLICE=26
	fFOV=$(echo "scale=2; 240/2"| bc)
	fZ=$(echo "scale=2; ((fSLICE=$fSLICE-1) * ${fTHICK})/2" | bc)

	to3d \
		-fse \
		-prefix ${subj}.fse \
		-session ${STRUC} \
		-xFOV ${fFOV}R-L \
		-yFOV ${fFOV}A-P \
		-zSLAB ${fZ}${fZ1}-${fZ}${fZ2} \
		${ORIG}/${efile}[23]i*


	#------------------------------------------------------------------------
	#
	#	Description: a
	#
	#		Purpose: a
	#
	#		  Input: a
	#
	#		 Output: a
	#
	#	  Variables: aSLICE (164) number of slices for anatomial SPGR image
	#				 aTHICK (1) Z-slice thickness for anatomial SPGR image
	#				 aFOV (128.00) half the Field of View for anatomial SPGR
	#				 			   (240/2 = 125.00)
	#				 aZ (81.50) Size of z dimension in anatomial SPGR image
	#				 	 		evaluated as Slices-1 * thickness divided by 2
	#				 aZ1 (L) Left Z-Slice dimmension of SPGR
	#				 aZ2 (R) Right Z-Slice dimmension of SPGR
	#
	#------------------------------------------------------------------------

	aZ1=L; aZ2=R; aSLICE=164; aTHICK=1
	aFOV=$(echo "scale=2; 256/2"| bc)
	aZ=$(echo "scale=2; ((aSLICE=$aSLICE-1) * ${aTHICK})/2"| bc)

	to3d \
		-spgr \
		-prefix ${subj}.spgr \
		-session ${STRUC} \
		-xFOV ${aFOV}A-P \
		-yFOV ${aFOV}S-I \
		-zSLAB ${aZ}${aZ1}-${aZ}${aZ2} \
		${ORIG}/${efile}[789]i*


	#------------------------------------------------------------------------
	#
	#	Description: a
	#
	#		Purpose: a
	#
	#		  Input: a
	#
	#		 Output: a
	#
	#	  Variables: a
	#
	#------------------------------------------------------------------------

	align_epi_anat.py \
		-dset1to2 -cmass cmass \
		-dset1 ${STRUC}/${subj}.spgr+orig \
		-dset2 ${STRUC}/${subj}.fse+orig \
		-cost lpa -suffix .cmass

	3dSkullStrip \
		-input ${STRUC}/${subj}.spgr.cmass+orig \
		-prefix ${STRUC}/${subj}.spgr.standard

	@auto_tlrc \
		-no_ss -suffix NONE \
		-base TT_N27+tlrc \
		-input ${STRUC}/${subj}.spgr.standard+orig

	3drefit -anat ${STRUC}/${subj}.spgr.standard+tlrc



	#------------------------------------------------------------------------
	#
	#	Description: a
	#
	#		Purpose: a
	#
	#		  Input: a
	#
	#		 Output: a
	#
	#	  Variables: a
	#
	#------------------------------------------------------------------------

	for (( i = 0; i < ${#subj_list[*]}; i++ )); do

		3dbucket \
			-aglueto ${ANAT}/TT_tap17.anat.stand+tlrc \
			${STRUC}/${subj}.spgr.standard+tlrc

		3drefit \
			-sublabel $i ${subj} \
			${ANAT}/TT_tap17.anat.stand+tlrc


		3dbucket \
			-aglueto ${ANAT}/TT_tap17.anat.fse+orig \
			${STRUC}/${subj}.fse+orig

		3drefit \
			-sublabel $i ${subj} \
			${ANAT}/TT_tap17.anat.fse+orig

	done

	3dTstat \
		-mean -median -stdev \
		-prefix ${ANAT}/TT_tap.anat.stats \
		${ANAT}/TT_tap17.anat.stand+tlrc

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#					Functional Image Preprocessing
#
#
#
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

for ((r=0; r<${#run[*]}; r++)) do

	run=${run[$r]}

	PREP=/Volumes/Data/TAP/${subj}/Prep/${run}
	GLM=/Volumes/Data/TAP/${subj}/GLM/${run}
	IRESP=/Volumes/Data/TAP/${subj}/GLM/${run}/IRESP

	#############################################################################
	#		Function:  _base:
	#
	#		 Purpose:  This function reads an outlier file looking for the lowest
	#				   integer, prints the NUMBER line - (x) to account for time
	#				   shifting and AFNI's zero-based counting preference. This
	#				   allows us to acquire a base volume to Register our data to
	#				   using 3dVolreg. The line number is representative of the
	#				   volume in the dataset, and following the subtraction, fits
	#				   with AFNI's conventions.
	#
	#				   The variable (x) is supplied by the variable 'trunc' +1.
	#				   It represents the number of volumes truncated +1 to
	#				   account for 0-based counting.
	#				   See the ${experiment}_profile for information regarding
	#				   how 'trunc' is defined.
	#
	#		   Input:  A list containing the outlier count for each volume of
	#				   a functional run
	#
	#		  Output:  A single integer value representing the most stable
	#				   volume in the dataset, which will act as the base
	#				   volume during registration.
	#############################################################################

	function _base: ()
	{
		 cat -n ${PREP}/${subj}.${run}.tshift.outs.1D \
		 	| sort -k2,2n | head -1 | awk '{print $1-1}'
	}



	#############################################################################
	#		Function:  _outplot:
	#
	#		Purpose:   This function will take the name of the file (e.g.
	#				   despike, tcat, tshift, etc) as input, and perform
	#				   3dToutcount to identify outliers time-points, then plot
	#				   the results using 1dplot
	#
	#		  Input:   The prefix name of the pre-processing step e.g. tshift
	#				   'Outcount_Plot tshift'
	#
	#		 Output:   ${subrun}.${step}.outs.txt, ${subrun}.${step}.outs.jpeg
	#
	#	  Variables:   step
	#
	#############################################################################

	function _outplot: ()
	{
		local step=$1

		3dToutcount \
			${PREP}/${subj}.${run}.${step}+orig \
			> ${PREP}/${subj}.${run}.${step}.outs.txt

		1dplot \
			-jpeg ${PREP}/${subj}.${run}.${step}.outs \
			${PREP}/${subj}.${run}.${step}.outs.txt
	}



	#------------------------------------------------------------------------
	#
	#	Description: a
	#
	#		Purpose: a
	#
	#		  Input: a
	#
	#		 Output: a
	#
	#	  Variables: tr (3500) repetition time in miliseconds
	#				 ntp (154 | 160) Number of time-points. Subjects 1-14 have
	#				 				 150 while subjects 15-18 have 160
	#
	#	       NOTE: fZ1, fZ2, fZ, fTHICK, fSLICE, and fFOV have been defined
	#				 elsewhere
	#
	#------------------------------------------------------------------------

	tr=3500;

	case $subj in
		TS00[1-9] )

			ntp=154
			;;

		TS01[0-4] )

			ntp=154
			;;

		TS01[5-8] )

			ntp=160
			;;
	esac

	to3d \
		-epan \
		-prefix ${subj}.${run}.epan \
		-session ${PREP} \
		-2swap \
		-text_outliers \
		-save_outliers ${PREP}/${subj}.${run}.outliers.txt \
		-xFOV ${fFOV}R-L \
		-yFOV ${fFOV}A-P \
		-zSLAB ${fZ}${fZ1}-${fZ}${fZ2} \
		-time:tz ${ntp} ${fSLICE} ${tr} \
		@${STIM}/offsets.1D \
		${ORIG}/${run}.*

	_outplot: epan



	#------------------------------------------------------------------------
	#
	#	Description: a
	#
	#		Purpose: a
	#
	#		  Input: a
	#
	#		 Output: a
	#
	#	  Variables: trunc (4 | 10 ) represents the number of timepoints to be
	#				  		removed from the function image
	#------------------------------------------------------------------------

	if [[ $npt = 154 ]]; then
		trunc=4
	else
		trunc=10
	fi

	3dTcat \
		-verb \
		-prefix ${PREP}/${subj}.${run}.tcat \
		${PREP}/${subj}.${run}.epan+orig'['${trunc}'..$]'

	_outplot: tcat

	echo "slices truncated = ${trunc}" > ${PREP}/${subj}.${run}.log.txt


	#------------------------------------------------------------------------
	#
	#	Description: 3dDespike
	#
	#		Purpose: a
	#
	#		  Input: a
	#
	#		 Output: a
	#
	#	  Variables: a
	#
	#------------------------------------------------------------------------

	3dDespike \
		-prefix ${PREP}/${subj}.${run}.despike \
		${PREP}/${subj}.${run}.tcat+orig

	_outplot: despike


	#------------------------------------------------------------------------
	#
	#	Description: a
	#
	#		Purpose: a
	#
	#		  Input: a
	#
	#		 Output: a
	#
	#	  Variables: a
	#
	#------------------------------------------------------------------------

	3dTshift \
		-verbose \
		-tzero 0 \
		-rlt+ \
		-quintic \
		-prefix ${PREP}/${subj}.${run}.tshift \
		${PREP}/${subj}.${run}.despike+orig

	_outplot: tshift

	#------------------------------------------------------------------------
	#
	#	Description: a
	#
	#		Purpose: a
	#
	#		  Input: a
	#
	#		 Output: a
	#
	#	  Variables: a
	#
	#------------------------------------------------------------------------

	cd ${PREP}


	echo "volume registered to = $( _base: ) " >> ${subj}.${run}.log.txt

	align_epi_anat.py \
		-anat ${STRUC}/${subj}.spgr.standard+orig \
		-anat_has_skull no \
		-epi ${subj}.${run}.tshift+orig \
		-big_move \
		-epi_strip 3dAutomask \
		-epi_base ${base} \
		-epi2anat -suffix .reg  \
		 -volreg on -volreg_opts  \
				-verbose -verbose -zpad 4 \
				-1Dfile ${GLM}/${subj}.${run}.dfile.1D \
		-tlrc_apar ${STRUC}/${subj}.spgr.standard+tlrc

	3dcopy ${subj}.${run}.tshift.reg+orig \
			${subj}.${run}.vr.reg+orig

	3dcopy ${subj}.${run}.tshift_tlrc.reg+tlrc \
			${subj}.${run}.vr.reg+tlrc

	rm ${subj}.${run}.tshift.reg+orig.*
	rm ${subj}.${run}.tshift_tlrc.reg+tlrc.*

	1dplot \
		-jpeg ${subj}.${run}.vr.reg \
		-volreg \
		-xlabel TIME \
		${GLM}/${subj}.${run}.dfile.1D


	_outplot: vr.reg



	#------------------------------------------------------------------------
	#
	#	Description: Smoothing
	#
	#		Purpose: a
	#
	#		  Input: a
	#
	#		 Output: a
	#
	#	  Variables: a
	#
	#------------------------------------------------------------------------

	filter=4.0

	3dBlurInMask \
		-preserve \
		-FWHM ${filter} \
		-automask \
		-prefix ${PREP}/${subj}.${run}.blur \
		${PREP}/${subj}.${run}.vr.reg+tlrc

	echo "Smoothing kernel = ${filter}mm" >> ${PREP}/${subj}.${run}.log.txt


	#------------------------------------------------------------------------
	#
	#	Description: Masking
	#
	#		Purpose: a
	#
	#		  Input: a
	#
	#		 Output: a
	#
	#	  Variables: a
	#
	#------------------------------------------------------------------------

	3dAutomask \
		-prefix ${PREP}/${subj}.${run}.fullmask \
		${PREP}/${subj}.${run}.blur+tlrc

	3dresample \
		-master ${PREP}/${subj}.${run}.fullmask+tlrc \
		-prefix ${PREP}/${subj}.${run}.spgr.resam \
		-input ${STRUC}/${subj}.spgr.standard+tlrc

	3dcalc \
		-a ${PREP}/${subj}.${run}.spgr.resam+tlrc \
		-expr 'ispositive(a)' \
		-prefix ${PREP}/${subj}.${run}.spgr.mask

	3dABoverlap \
		-no_automask ${PREP}/${subj}.${run}.fullmask+tlrc \
		${PREP}/${subj}.${run}.spgr.mask+tlrc \
		2>&1 | tee -a ${PREP}/${subj}.${run}.mask.overlap.txt

	3dABoverlap \
		-no_automask \
		${ANOVAMask}/N27.mask+tlrc \
		${PREP}/${subj}.${run}.spgr.mask+tlrc \
		2>&1 | tee -a ${PREP}/${subj}.${run}.spgr.mask.overlap.txt

	echo "( ${subj}.${run} / N27 ) = \
		$( cat ${PREP}/${subj}.${run}.spgr.mask.overlap.txt \
		| tail -1 | awk '{print $8}')" \
		>> ${ANOVAMask}/N27.mask.overlap.txt

	3dcopy ${PREP}/${subj}.${run}.fullmask+tlrc ${GLM}



	#------------------------------------------------------------------------
	#
	#	Description: Scale
	#
	#		Purpose: a
	#
	#		  Input: a
	#
	#		 Output: a
	#
	#	  Variables: a
	#
	#------------------------------------------------------------------------

	3dTstat \
		-prefix ${PREP}/rm.${subj}.${run}.mean \
		${PREP}/${subj}.${run}.blur+tlrc

	3dcalc \
		-verbose \
		-float \
		-a ${PREP}/${subj}.${run}.blur+tlrc \
		-b ${PREP}/rm.${subj}.${run}.mean+tlrc \
		-c ${PREP}/${subj}.${run}.fullmask+tlrc \
		-expr 'c * min(200, a/b*100)*step(a)*step(b)' \
		-prefix ${PREP}/${subj}.${run}.scale


	3dcopy ${PREP}/${subj}.${run}.scale+tlrc ${GLM}

