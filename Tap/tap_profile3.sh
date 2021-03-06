. $DRIVR/exp_profile
####################################################################################################
								########### START OF MAIN ############
####################################################################################################
# This list specifies variables specifc to the TAP study. Sections include those designated for
# directory specific path variables,
# These are path variables that will be specified in the individual program scripts
####################################################################################################
#
home_dir=${TAP}
anova_dir=${TAP}/ANOVA/${mod}/${run}
ICA_dir=${TAP}/ICA/${run}
GLM_dir=${TAP}/GLM
ANAT_dir=${TAP}/Anatomical
subj_dir=${TAP}/${subj}
orig_dir=${subj_dir}/Orig
anat_dir=${subj_dir}/Struc
prep_dir=${subj_dir}/Prep
glm_dir=${subj_dir}/GLM
test_dir=${subj_dir}/Test
####################################################################################################
# Condition name decision maker
####################################################################################################
#
if [ "${run}" = "SP1" ]; then
    cond1=animal
    cond2=food
elif [ "${run}" = "TP1" ]; then
    cond1=old
    cond2=new
else
    cond1=male
    cond2=female
fi

alevel1=$cond1
alevel2=$cond2
####################################################################################################
# Deconvolution; Hemodynamic Response Model specific variables
####################################################################################################
# For the default WAV and GAM models

mod=GAM
if [ "${hrm}" = "WAV" ]; then
    mod=WAV
elif [ "${hrm}" = "GAM" ]; then
    mod=GAM
fi
####################################################################################################
#
# Names for files. Naming hierachy should follow this pattern: subj, run, mod, cond, brik
# Indentation is for readability
####################################################################################################
spgr=${subj}.spgr
fse=${subj}.fse

subrun=${subj}.${run}
submod=${subrun}.${mod}
subcond1=${submod}.${cond1}
subcond2=${submod}.${cond2}
	runmod=${run}.${mod}
	runcond1=${run}.${mod}.${cond1}
	runcond2=${run}.${mod}.${cond2}
####################################################################################################
# ANOVA and Group-specific variables
####################################################################################################

runmean=${runmod}.mean
runbase=${runmod}.base
rundiff=${runmod}.diff
runcontr=${runmod}.contr
	cond1v2=${cond1}.vs.${cond2}
	cond2v1=${cond2}.vs.${cond1}


if [ "${clust}" = "1640" ]; then
	plvl=05; thr=2.160
elif [ "${clust}" = "1709" ]; then
	plvl=04; thr=2.281
elif [ "${clust}" = "1759" ]; then
	plvl=03; thr=2.435
elif [ "${clust}" = "1875" ]; then
	plvl=02; thr=2.651
elif [ "${clust}" = "2044" ]; then
	plvl=01; thr=3.014
elif [ "${clust}" = "2324" ]; then
	plvl=005; thr=3.374
elif [ "${clust}" = "2890" ]; then
	plvl=001; thr=4.214
fi

####################################################################################################
# FSE Preprocessing parameters
####################################################################################################

nfs=154 #number of functional scans
nas=26 #number of anatomical slices
tr=3500 #the GAM
thick=5 #Z-slice thickness
z1=I #Slice acquisition direction
fov=240 #field of view
####################################################################################################
# For calculating xyz sizes for functional and structural (fse) reconstruction in to3d
# Calculate the zslab value ((nas-1)* thick)/2), yFOV
####################################################################################################

x=`expr ${nas} - 1`
y=`echo "scale=2; ${x} * ${thick}"| bc`
z=`echo "scale=2; ${y}/2"| bc`
halffov=`echo "scale=2; ${fov}/2"| bc`
####################################################################################################
# Spgr Preprocessing parameters
####################################################################################################

nasspgr=164 #number of anatomical slices
thickspgr=1 #Z-slice thickness
z1spgr=L #Slice acquisition direction
fovspgr=256 #field of view for spgr
####################################################################################################
# For calculating xyz sizes for structural reconstruction in to3d
# Calculate the zslab value ((nas-1)* thick)/2), yFOV
# I had to include spgr variables because the tap study uses different parameters for that scan
####################################################################################################

xspgr=`expr ${nasspgr} - 1`
yspgr=`echo "scale=2; ${xspgr} * ${thickspgr}"| bc`
zspgr=`echo "scale=2; ${yspgr}/2"| bc`
anatfov=`echo "scale=2; ${fovspgr}/2"| bc`
####################################################################################################