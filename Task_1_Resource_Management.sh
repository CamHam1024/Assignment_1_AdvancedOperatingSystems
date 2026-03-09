#!/bin/bash

#Setting up base directories and file names
#collects the directory path for the script itself (the logs will always be in the same place the script is)
#cd is a command that sets the current directory, in this case SCRIPT_DIR will store the directory of the Bash Source (the application itself)
#SCRIPT_DIR Also uses dirname which extracts the directory  of the specified file, in this case this application itself.
#This is justified becasue it will allow the script to be placed anywhere and all relivent files will be togerher.
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";

#the directory for the logs, Uses SCRIPT_DIR to set the Base directory for this app
BASE_DIR="$SCRIPT_DIR/logsDir"
#directory for the log archive
ARCHIVE_DIR="$BASE_DIR/ArchiveLogs"
#directory for the log file
LOG_FILE="$BASE_DIR/System_Monitor_Log.txt"

#log file size warning
LogArchiveSize="$( numfmt --from=iec 500M )" #in bytes
ArchiveWarn="$( numfmt --from=iec 1000M )" #Warnign if the log files reaches 1G
#Challange: Trouble was had figuring out how to get this in human readable format (MB and GB)
#Using numfmt allows me to convert 500M into bites helping it be more human readable in code.

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

logSize=$(stat -c %s "$LOG_FILE") #this file uses stat to get the file size of the log file
if [[ logSize -gt LogArchiveSize  ]]; then #if logSize is Greater then warning
	echo "Log file exceeded size limit, Archiving..." 

	mkdir -p "$ARCHIVE_DIR" #create archive folder when needed
	cd "$BASE_DIR" #set the directory to Base directory
	LN="$(basename "$LOG_FILE")" #preserve the file name of the log file
	zip -m archivedlog.zip "$LN"  #moves the log file to a zipped folder which is then created in the base dir
	
	# renaming and moving the archive
	ZN=ArchivedLog-"$(date '+%Y-%m-%d %H:%M:%S' )".zip 
	mv archivedlog.zip "$ZN" 
	mv "$ZN" "$ARCHIVE_DIR"

	echo
	#Archive Directory Warning
	ADW=$(du -sb "$ARCHIVE_DIR" | awk '{ print $1 }')

	if [[ ADW -gt ArchiveWarn  ]]; then
        	echo
        	printf "${RED}WARNING ARCHIVE FOLDER OVER 1G.${NC}"
        	echo
	fi
 
fi
echo
}

#Setting up the Menu
print_menu(){
printf "${GRN}Base Directory: $BASE_DIR${NC}"
echo 
printf "${YLW}"
echo "============"
echo "CCCU Data Center Process and Resource Management System."
echo "1: Current system CPU and Memory Usage."
echo "2: Base Directory Disk Usage"
echo "3: List Highest Memory consuming Processes."
echo "4: Terminate a process."
echo "5: Exit"
echo "============"
printf "${NC}"
}

cpu_usage(){
printf "${GRN}Current CPU and Memory Useage ${NC}"
echo
CPU_USAGE=$(top -bn1 | awk '/Cpu/ { print $2 }') #calculates the current CPU Usage
MEMORY_USAGE=$(free -m | awk '/Mem/ { print $3 }') #calculates the current Memory useage

#Prints out the results
printf "${GRN}CPU USEAGE: ${NC}" #CPU Usage %
echo "$CPU_USAGE%"
printf "${GRN}MEM USEAGE: ${NC}" #Memory Usage MB
echo "$MEMORY_USAGE MB"
sleep 1s

#Log the event in the LOG FILE
log_event "System CPU and MEMORY checked CPU: $CPU_USAGE%, MEM: $MEMORY_USAGE MB"
}

dir_usage(){
printf "${GRN}Directory Disk Useage${NC}"
echo
#du reads the disk useage of the directoy, printing it in a human readable format using the -ch option
du -ch "$SCRIPT_DIR"
sleep 1s
#Log The Event
log_event "$SCRIPT_DIR disk useage checked"
}

list_highest(){
printf "${GRN}Top 10 CPU Consuming processes ${NC}"
echo
# ps returns a list of 10 processes that using --sort=-%cpu to sort them by cpu useage
ps -eo cmd,pid,nice,user,%cpu,%mem --sort=-%cpu | head
sleep 1s
#Log the event
log_event "Top 10 CPU Hungry Processes checked"
}

terminate_process(){
#Select Process by its PID
read -r -p "Please Type Process ID (Pid): " pid #type desired process

#test compairs files and strings, and is used here to check if a PID exists
if test -d /proc/$pid; then #Checks if the process Exists
	read  nice cpu mem cmd < <(ps ho nice,%cpu,%mem,cmd $pid) #split the reading of ps into multiple variables 
	echo
	printf "${GRN}Process: $cmd ni: $nice CPU: $cpu Mem: $mem ${NC}\n" #Displays process
	echo
	
	if  [[ $nice -ge 0 ]]; then #if the Nice value is greater or Equal to 0 ask to terminate
		read -r -p "Would you like to terminate this process y/n: " TC
		
		if [[ "$TC" == "Y" || "$TC" == "y" ]]; then #ask to terminate
			#Kill the process
			kill -9 $pid
			printf "${GRN}Process $pid has been terminated... ${NC}"
			
			sleep 1s
			#Log the event
			log_event "Process (pid: $pid , nice: $nice) has been terminated"
			return
		else
			#Exit out of the command
			printf "${RED}Command Cancelled... ${NC}"
			sleep 1s
			return
		fi
	else
		#If the process is critical (below nice 0) refuse to terminate
		printf "${RED}Cannot terminate a process with a priority of $nice\nOnly processes of 0 or above can be terminated "
		
		sleep 1s
		#Log the event
                log_event "Process (pid: $pid , nice: $nice) failed to terminate (Critcal process)"
		return
	fi
else
	printf "${RED}This Process doesn't exist...${NC}"
	sleep 1s
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

main_loop(){
echo
mkdir -p "$BASE_DIR"
#checks to make sure  a log file exists
if [[ ! -f "$LOG_FILE"  ]]; then
	touch "$LOG_FILE"
	
	#Creates a log file of a certain size for testing
	#dd if=/dev/zero of="$LOG_FILE" bs=1M count=1500 status=none

	log_event "Log Created"

	printf "${GRN}System Log created"
else
	log_event "Management Tool Started."
	printf "${GRN}Log file already exists in directory"
fi
echo

while true; do
print_menu
read -r -p "Select an Option: " choice #Reads User input and stores it in "choice"
echo
case "$choice" in #compairs the user input 'choice' with patterns in the case
	1) cpu_usage ;;
	2) dir_usage ;;
	3) list_highest ;;
	4) terminate_process ;;
	5) exit_bye ;;
	x) exit ;;
	*) echo "Invalid Choice..." ;;
	esac
	echo
	done
}

main_loop
