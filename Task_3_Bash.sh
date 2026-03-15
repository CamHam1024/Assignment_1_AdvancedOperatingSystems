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
StudentID="1"
password="MTB"

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
				cp $subfile "$newFilePath" # Copies The file to completed folder, preserving the origional
				
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
# Tell the User the account is locked
        printf "${RED}ACCOUNT IS LOCKED NEW Attempts in 60${NC}\n"
	#check if already exists
	#log result
else
	# The file for submission doesnt exist
	printf "${RED}This File Doesnt Exist${NC}\n"
	sleep 1s
fi
}

check_submission(){
#Read what file you want checked, TBH this is similar to whats being done in submit()
read -r -p "File to be submitted (directory): " subfile

if [[ -f "$subfile" ]]; then
        file="$(basename "$subfile")" # Extract the file name from directory
	
	# Check if the file has already been submitted
        newFilePath="$SUBMITTED/$file" # Creates a new file path to check with 
	if [[ -f $newFilePath  ]]; then
		printf "${GRN}${file} has been submitted.${NC}\n"
		sleep 1s
	else
		printf "${RED}${file} has Not been submitted yet.${NC}\n"
		sleep 1s
	fi
else
	printf "${RED}There is no such file in directory.${NC}\n"
	
	
# Displays Directory typed for error tracking.
	printf "${RED}Typed Directory: ${NC}${subfile}\n"
fi

}

list_submission(){
# This Loop prints out all of the files in the directory as a long directory string
printf "${GRN}Currently Submitted Files.${NC}\n============\n"
for submissions in "$SUBMITTED"/*
do
	# This converts and prints JUST the file without the rest of the directory
	printf "${GRN}$(basename "$submissions")\n${NC}"
done
printf "============\n"
}

# A function for setting Usernames and Passwords
setUserPass(){
#Student ID and Password defaults
StudentID="1024"
password="MTB"
attempts=3 # Number wrogn attempts before lockage.

read -r -p "Please Chose a StudentID: " StudentID
read -r -p "Please Chose a Password: " password
printf "${GRN}Chosen Username: ${StudentID} | Password: ${password}${NC}\n\n"

}

login_sim(){
# Make the user type their username and password
read -r -p "Please enter your StudentID: " StudidAttempt
read -r -p "Please enter your Password: " passAttempt
if [[ attempts -gt 0  ]]; then
	# Check if Username and password are correct
	if [[ $StudidAttempt = $StudentID && $passAttempt = $password  ]]; then
		# Congradulations Youre in!
		printf "\n============\n${GRN}Congradulations You're In!${NC}\n============\n"
	
		# Log Event
		log_event "Successful Login attempt recorded"
	else
		# Counts the avalible attempts down by 1
		attempts=$((attempts-1))

		# Print unsucessful message
		printf "\n${RED}Wrong username or password. Attempts remaining: ${attempts}\n"

		# Time when failed attempt occured
		SECONDS=0 # This Global tracks time since script has started, setting it here to 0 for time tracking
	fi
else
	# Number of seconds since account got locked
	timeSinceFail=$SECONDS
	
	# Tell the User the account is locked, with time till unlock
	 printf "${RED}ACCOUNT IS LOCKED. Try again in $((60 - timeSinceFail)) second${NC}\n"

	# Checks that the time since last fail is less then 60 seconds
	if [[ $timeSinceFail -lt 10 ]]; then
		# Log Suspicious activity
		log_event "Suspicious activity detected - repeated login attempts after account lock."
	else
		# after 60 seconds reset attempts
		attempts=3 
	fi
fi
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
	
	printf "${GRN}Test Files Created at ${SUBMIT_DIR}${NC}\n"
fi

}

main_loop(){
echo
# Creates Files for testing
createTestFiles

# Set User Password amd Username
setUserPass

# Checks to make sure  a log file exists
if [[ ! -f "$LOG_FILE"  ]]; then
	touch "$LOG_FILE"
	printf "${GRN}System Log created"
else
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
