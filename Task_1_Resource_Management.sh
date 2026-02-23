#!/bin/bash

#Setting up base directories and file names
SELECTED_DIR = "$HOME"
BASE_DIR="$HOME/AssignmentDirectory"
ARCHIVE_DIR="$BASE_DIR/ArchiveLogs"
LOG_FILE="$BASE_DIR/System_Monitor_Log.txt"
WARNING_LIMIT_MB=500

#optional stuff :)
RED='\033[1;31m'
GRN='\033[1;32m'
YLW='\033[1;33m'
NC='\033[0m'

#Seting up the Admin Log function
log_event(){
local msg="$1"
printf"%s %s\n" "$(date'+%Y-%m-%d %H:%M:%S')" "$msg" >> "$LOG_FILE"
}

#Setting up the Menu
print_menu(){
printf "${YLW}"
echo
echo "============"
echo "CCCU Data Center Process and Resource Management System."
printf "${RED}"
echo "t: Test print varaibles. Useful!"
printf "${YLW}"
echo "1: Current CPU and Memory Usage."
echo "2: Display Directory Disk Usage"
echo "3: List Highest Memory consuming Processes."
echo "4: Terminate a process."
echo "5: Exit"
echo "============"
printf "${NC}"
}

test_print(){
echo
printf "HOME Var: ${RED}$HOME${NC}"
echo
printf "BASE Var: ${RED}$BASE_DIR${NC}"
echo
printf "LOG FILE Var: ${RED}$LOG_FILE${NC}"
}

cpu_usage(){
echo "Not Implimented Yet"
}

dir_usage(){
echo "Not Implimented Yet"
}

list_highest(){
echo "Not Implimented Yet"
}

terminate_process(){
echo "Not Implimented Yet"
}

exit_bye(){
read -r -p "Are you Sure? y / n: " conf #Asks if you are sure you want to quit
if [[ "$conf" == "Y" || "$conf" == "y"  ]]; then
	echo "Bye Bye!" #If you type "Y" or "y" print out Bye Bye and exit the program
	exit	
else
	#ANY other input will just return you back into the program
	return
fi
}

main_loop(){
mkdir -p "$BASE_DIR"
#checks to make sure  a log file exists
if [[ ! -f "$LOG_FILE"  ]]; then
	touch "$LOG_FILE"
	printf "${GRN}System Log Created. At $LOG_FILE ${NC}"
else
	printf "${GRN}Log File Already Exists. ${NC}"
fi

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
	t) test_print ;;
	*) echo "Invalid Choice..." ;;
	esac
	echo
	done
}

main_loop
