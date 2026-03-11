#!/bin/python3
#Imports
import os
import sys
import ast
from datetime import datetime # for time stamp generation
#import numpy as np # For creating job list and dictionary
import pandas as pd

# Coloured for UI elements
RED = "\033[1;31m"
GRN = "\033[1;32m"
YLW = "\033[1;33m"
NC = "\033[0m"

# Time Stamp
time = datetime.now()

# Creates a list for app useage.
pend = [] # List for active pending jobs.
comp = [] # List for completed jobs

# Log File
def logFile(event):
	log = "scheduler_log.txt"

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

	# Append to working List
	pend.append(jobDict) # this is so it shows up immediatly in the pending jobs.

	# write to the job Queue
	with open("job_queue.txt", "a") as f:
		f.write(f"{jobDict}\n")
	print(f"{GRN}Job has been added to queue.{NC}")

	# Log event
	logFile(f"Job {jobDict['StudentID']} Added. ")
	input(f"\n{GRN}Press any key to continue{NC}")

def createList(): # Creates a runnign list for displaying completed n pending files
	pend = []
	# Reading the Pending Job File on start up
	with open("job_queue.txt") as f: # comp = [] , pend = []
		for job in f: #iterates through the Pending_Jobs.txt file
			if job.strip(): # prevents any blank lines from being added
				dictpen = ast.literal_eval(job.strip()) # reads the dictionary in the file n makes it a real dictionary
				pend.append(dictpen)
	comp = []
	# Reading the Completed Job File on startup
	with open("completed_jobs.txt") as f:
		for job in f: #iterates through the txt file
			if job.strip(): # prevents any blank lines from being added
				dictcomp = ast.literal_eval(job.strip()) # reads the dictionary in the file n makes it a real dictionary
				comp.append(dictcomp)


def viewPending():
	print(f"{GRN}Displaying Current Job Queue.{NC}")
	df = pd.DataFrame(pend)
	if df.empty: # Checks if the pend list is empty or not.
		print(f"{YLW}There is no current jobs.{NC}") 
	else: # if its not empty Print the list as a pandas table
		print(f"{YLW}{df}{NC}")

	print()
	input(f"\n{GRN}Press any key to continue{NC}")
	
	#Log The Eveent
	logFile(f"Pending Jobs Checked. ")

def viewCompleted():
	# Same code as viewPending but with the completed job list.
	print(f"{GRN}Displaying Completed Jobs.{NC}")
	df = pd.DataFrame(comp)
	if df.empty:
		print(f"{YLW}There is no completed jobs.{NC}")
	else: 
		print(f"{YLW}{df}{NC}")
	print()
	input(f"\n{GRN}Press any key to continue{NC}")
	
	#Log The Event
	logFile(f"Completed Jobs Checked. ")

# Job Processing
def processJob():
	if pend:
		pjPriority()
	else:
		print(f"{YLW}There is no jobs to process.{NC}")

# Process Job Styles
def pjPriority(): # Priority Process
	# Sort the list of jobs by Priority number
	sortedList = sorted(pend, key=lambda d: d['Priority'], reverse=True) # Lambda allows the collection of a dict key, reverse makes it desending. 
	df = pd.DataFrame(sortedList)
	#print(df) # Print list for testing
	
	#Iterate through List completing tasks
	for j in sortedList:
		print(f"{YLW}Job {j['Job_Name']} of priority {j['Priority']} being completed...{NC}")
		
		# Write completed Tasks to completed_jobs.txt
		with open("completed_jobs.txt", "a") as f:
			f.write(f"{j}\n")
		
		# add to comp
		comp.append(j)
		
		#Log The Event
		logFile(f"Job completed. stuID: {j['StudentID']} job:  {j['Job_Name']} time: {j['Time_Expected']} priority: {j['Priority']} ")
		
	#remove from Pending
	open("job_queue.txt", "w").close() # Empties the job_queue.txt

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

def mainLoop():
	# Variable set up.
	# Directory Paths
	ScriptDir = os.getcwd()
	
	# Creates the required files if they dont exist
	file = open("scheduler_log.txt", "a") # Log file
	file = open("job_queue.txt", "a") # Pending jobs
	file = open("completed_jobs.txt","a") # Completed jobs

	createList() # Function for reading the completed and pending jobs from txt files

	print("Script Directory: " + ScriptDir)
	#logFile("Testing Log")

	
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

