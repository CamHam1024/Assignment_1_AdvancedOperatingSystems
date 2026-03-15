#!/bin/bash

#Setting up base directories and file names
#collects the directory path for the script itself (the logs will always be in the same place the script is)
#cd is a command that sets the current directory, in this case SCRIPT_DIR will store the directory of the Bash Source (the application itself)
#SCRIPT_DIR Also uses dirname which extracts the directory  of the specified file, in this case this application itself.
#This is justified becasue it will allow the script to be placed anywhere and all relivent files will be togerher.
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";

# Directory for the log archive
SUBMIT_DIR="$SCRIPT_DIR/files_for_submission_bash"
SUBMITTED="$SCRIPT_DIR/submitted_files_bash"

# Directory for the log file
LOG_FILE="$SCRIPT_DIR/bash_logFile.txt"
SUBMIT_LOG="$SCRIPT_DIR/bash_submission_log.txt"

# Log file size warning
maxSubmitSize="$( numfmt --from=iec 5M )" #Rejection size over 5MB

# Array for Users and Passwords and Files
#usernames=("1111" "2222" "3333") # for testing plz remove
#passwords=("Middy" "Alex" "Lilli") # ditto

#Student ID and Password
StudentID="1024"
password="MiddyTheBird"

#Text colour codes, rather simple using this in printf "" will change the colour of the text printed
RED='\033[1;31m'
GRN='\033[1;32m'
YLW='\033[1;33m'
NC='\033[0m' #No Colour (resets the formatting

#Seting up the Admin Log function
#Useage: log_event("Log even description")
log_event(){
local msg="$1 " #sets the  printed log message based pm the first argument of the function
echo
#prints the date and time in a Year Month Day format this is the ISO 8601 time standard
printf "%s %s\n" "$(date '+%Y-%m-%d %H:%M:%S' ) " "$msg" >> "$LOG_FILE"
printf "${NC}"
echo "Log file has been updated."
echo
}

#Seting up the Submission Log
log_sub_event(){
local msg="$1 " #sets the  printed log message based pm the first argument of the function
echo
#prints the date and time in a Year Month Day format this is the ISO 8601 time standard
printf "%s %s\n" "$(date '+%Y-%m-%d %H:%M:%S' ) " "$msg" >> "$SUBMIT_LOG"
printf "${NC}"
echo "Log file has been updated."
echo
}


#Setting up the Menu
print_menu(){
printf "${GRN}Base Directory: $SCRIPT_DIR${NC}"
echo 
printf "${YLW}"
echo "============"
echo "CCCU Examination submission System."
echo "1: Submit an assignment."
echo "2: Check Submission."
echo "3: List All Submissions."
echo "4: Log in."
echo "5: Exit"
echo "============"
printf "${NC}"
}

submit(){
printf "${GRN}Submit an Assignment.${NC}\n"
# Tasks here:
# Capture Directory
# For testing: subfile="/home/kali/Documents/AdvOp-Ass-1/Task-3/files_for_submission_bash/submitdocx.docx"

read -r -p "File to be submitted (directory): " subfile

# Checks if the file for submitting actually exists first.
if [[ -f "$subfile" ]]; then
	file="$(basename "$subfile")" # Extract the file name from directory
	printf "${file}\n"  # Print the file name for validation uvu

	fExtent="${file##*.}" #this gets the files extention (.txt or .pdf)
	printf "${fExtent}\n" # Print Extension for Validation

	# Check File Type
	if [[ $fExtent = "docx" || $fExtent = "pdf" ]]; then # Checks if file is a docx or pdf file
		# Check File Size
		filesize=$(stat -c %s "${subfile}") # Get the file size using stat		
		if [[ $filesize -lt maxSubmitSize  ]]; then
			# Check if the file has already been submitted
			newFilePath="$SUBMITTED/$file" # Creates a new file path to check with 

			if [[ ! -f $newFilePath  ]]; then
				printf "${GRN}Assignment $file has been successfully submitted by student id$StudentID${NC}\n"
				cp $subfile "$newFilePath" # Move The file to completed folder
				
				# Log the submission
				log_sub_event "Assignment ${file} has been successfully submitted by student id${StudentID}"
				sleep 1s
			else
				printf "${RED}File has already been submitted.${NC}\n"
				
				# Log the submission filure
				log_sub_event "Student id${StudentID} tried uploading ${file} but it already exists"
				sleep 1s
			fi
		else
			printf "${RED}Submitted File Is Too Large. (5MB Maximum)${NC}\n"
			
			# Log the submission failure
			log_sub_event "student id${StudentID} tried uploading ${file} but it was bigger then 5MB"
			sleep 1s 
		fi
	else
		printf "${RED}Only .docx or .pdf files accepted.${NC}\n"

		# Log the submission failure
		log_sub_event "student id${StudentID} tried uploading ${file} but the file wasn't a .pdf or .docx" 
		sleep 1s
	fi
	#check if already exists
	#log result
else
	# The file for submission doesnt exist
	printf "${RED}This File Doesnt Exist${NC}\n"
	sleep 1s
fi
}

check_submission(){
printf "${GRN}Not Implimented Yet..${NC}"
}

list_submission(){
printf "${GRN}Not Implimented Yet...${NC}\n"

for f in "${submissions[@]}"; do

	printf "$f \n"

done;

}

login_sim(){
printf "${GRN}Not Implimented Yet....${NC}"
}

exit_bye(){
read -r -p "Are you Sure? y/n: " conf #Asks if you are sure you want to quit
if [[ "$conf" == "Y" || "$conf" == "y"  ]]; then
	echo "Bye Bye!" #If you type "Y" or "y" print out Bye Bye and exit the program
	exit
else
	#ANY other input will just return you back into the program
	return
fi
}

createTestFiles(){
if [[ ! -d "$SUBMIT_DIR" ]]; then
	# This Script creates the files we will be testing with
	mkdir -p "$SUBMIT_DIR" #Create the Submission Directory if its missing
	mkdir -p "$SUBMITTED" #Creates the Submitted Directory

	# Make Valid Files
	touch "$SUBMIT_DIR/submitdocx.docx"
	printf "This is a Word Document." >> "$SUBMIT_DIR/submitdocx.docx"

	touch "$SUBMIT_DIR/submitpdf.pdf"
	printf "This is a PDF Document." >> "$SUBMIT_DIR/submitpdf.pdf"

	# Make Invalid Files
	touch "$SUBMIT_DIR/submittxt.txt"
	printf "This is a PlainText Document." >> "$SUBMIT_DIR/submittxt.txt"

	touch "$SUBMIT_DIR/submitLRGpdf.pdf"
	dd if=/dev/zero of="$SUBMIT_DIR/submitLRGpdf.pdf" bs=1M count=10 status=none
	
	printf "${GRN}Test Files Created at ${SUBMIT_DIR}${NC}"
fi

}

main_loop(){
echo
# Creates Files for testing
createTestFiles

# Checks to make sure  a log file exists
if [[ ! -f "$LOG_FILE"  ]]; then
	touch "$LOG_FILE"

	log_event "Log Created"

	printf "${GRN}System Log created"
else
	log_event "Management Tool Started."
	printf "${GRN}Log file already exists in directory"
fi
echo
# Creates Submission Log
if [[ ! -f "$SUBMIT_LOG"  ]]; then
        touch "$SUBMIT_LOG"

        printf "${GRN}Submission Log Created."
fi  
echo


while true; do
print_menu
read -r -p "Select an Option: " choice #Reads User input and stores it in "choice"
echo
case "$choice" in #compairs the user input 'choice' with patterns in the case
	u) create_user ;;
	1) submit ;;
	2) check_submission ;;
	3) list_submission ;;
	4) login_sim;;
	5) exit_bye ;;
	x) exit ;;
	*) echo "Invalid Choice..." ;;
	esac
	echo
	done
}

main_loop
