# The shebang line i.e. "#!/bin/bash" OR source line i.e.  ". $PROFILE/${1}_profile.sh"
####################################################################################################
# Program name
# Author and Date
# Acknowledgments if any
# Description of what the program does (one or two sentences)
# expected input - sample input
# expected output  -> output 
# if necessary, provide an example of the expected input of the expected command-line options. 
####################################################################################################
# If you are declaring any variables, do that at the beginning of the script just before the opening
# echo. Be sure to provide a description for each
####################################################################################################
echo "-------------------------------- Script.name.sh ----------------------------------"
echo "Short description of what program/script does (try to keep it under 80 character"
echo "-------------------------------- ${variable1} ${variable2}--------------------------------"
echo ""
####################################################################################################



####################################################################################################
# Always provide a comment block ABOVE the line of code. Create a comment block for each process, as 
# well as a short description of what it is doing, and any notes or gotchas to watch out for.  
# Always make a newline before entering the code, this will make it easier to see the code. Rest the
# code on top of the next comment block. See the below example
####################################################################################################

cat temp.report.${subrun} | awk -v OFS='\t' '$1=$1' >> Report.${subrun}.txt
####################################################################################################
# Be sure to include any notes about buggy processes or unused code, better to comment it out than
# to delete it and potentially loose that solution all together. 
####################################################################################################


####################################################################################################
Finish the program/script with a final comment line block with nothing underneath. 

