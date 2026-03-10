#!/bin/python3
#Imports
import os;
import sys;
from datetime import datetime; # for time stamp generation
import numpy as np # For creating job list and tuple

# Coloured for UI eliments
RED = "\033[1;31m"
GRN = "\033[1;32m"
YLW = "\033[1;33m"
NC = "\033[0m"

# Log File
def logFile(event):
	log = "scheduler_log.txt"
	# Time stamp generator
	time = datetime.now()

	with open(log, "a") as f:
		f.write(f"Event: {event} TimeStamp: {time} \n")

# Option Scripts.
def submitJob():
	# Empty out Dictionary
	# A Dictonary is used as i can have key:value pairs
	jobDict = {}

	# Get Job Intomation
	stuID = input(f"{GRN}Student ID: ")
	jobName = input(f"{GRN}Job Name: ")
	
	# Check if time is an int
	estTime = ""
	while estTime.isdigit() == False: # Checks if the variable is a digit.
		estTime = input(f"{GRN}Estemated Time (seconds): ")
		
		if estTime.isdigit() == False: # if not will ask you again.
			print(f"{YLW}Please Enter only a number.{GRN}")

	# Check if Priority is an int
	priority = ""
	while priority.isdigit() == False:
		priority = input(f"{GRN}Job Priority (1 - 10): ")

		if priority.isdigit() == False:
			print(f"{YLW}Please Enter only a number.{GRN}")

	print(f"{NC}")

	# Ansemble  Dictonary
	jobDict = {"StudentID": stuID, "Job_Name": jobName, "Time_Expected": int(estTime), "Priority": int(priority)}
	print(jobDict)
	
	# write to the job Queue
	with open("job_queue.txt", "a") as f:
		f.write(f"{jobDict}\n")
	print(f"{GRN}Job has been added to queue.{NC}")

	# Log event
	logFile(f"Job {jobDict['StudentID']} Added. ")

def viewPending():
	print(f"{YLW}Not Implimented Yet...{NC}")

def viewCompleted():
	print(f"{YLW}Not Implimented Yet...{NC}")

def processJob():
	print(f"{YLW}Not Implimented Yet...{NC}")

# Process Job Styles
def pjPriority(): # Priority Process
	print(f"{YLW}Not Implimented Yet...{NC}")

def pjRoundRobin(): # Round Robin Process
	print(f"{YLW}Not Implimented Yet...(Optional){NC}")
# ===========

def exitBye():
	# Gets Player Input for program closing confirmation.
	option = input(f"{GRN}Exit the program? Y/N: ")
	print(f"{NC}")

	match option:
		case "y" | "Y": # If you type Y or y exit the program.
			sys.exit()
		case _: # If any other input exit back into the program.
			print(f"")

def menuDraw():  
        print(f"{YLW}============{NC}")
        print(f"{YLW}Welcome to the Job Scheduler, Select an Option{NC}")
        print(f"{YLW}============{NC}")
        print(f"{YLW}1. Submit a Job.{NC}")
        print(f"{YLW}2. View Pending Jobs.{NC}")
        print(f"{YLW}3. View Completed Jobs.{NC}")
        print(f"{YLW}4. Process Jobs.{NC}")
        print(f"{YLW}5. Exit Scheduler.{NC}")
        print(f"{YLW}============{NC}")
        print(f"")

def mainLoop():
	# Variable set up.
	# Directory Paths
	ScriptDir = os.getcwd()
	
	# Creates the required files if they dont exist
	file = open("scheduler_log.txt", "a") # Log file
	file = open("job_queue.txt", "a") # Pending jobs
	file = open("completed_jobs.txt","a") # Completed jobs

	print("Script Directory: " + ScriptDir)
	logFile("Testing Log")
	# Create Log file if one doesnt exist.
	
	while True: # A Perpetuial While loop for keeping the programm running.
		# Draw the Main Menu.
		menuDraw()
	
		# Ask User for Menu Option and case.
		option = input(f"{GRN}Please Select an option 1 - 5: ")
		print(f"{NC}")
		
		# Options Avalible.
		match option:
			case "1":
				submitJob()
			case "2":
				viewPending()
			case "3":
				viewCompleted()
			case "4":
				processJob()
			case "5":
				exitBye()
			case "x": #to exit out of the program without a confirmation
				break
			case _:
				print(f"{RED}That is not an option: {NC}")

mainLoop()
