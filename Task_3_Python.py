#!/bin/python3

#Imports
import os
import sys
import time as T
from datetime import datetime # for time stamp generation
import time
import shutil # for copying files

# Coloured for UI elements
RED = "\033[1;31m"
GRN = "\033[1;32m"
YLW = "\033[1;33m"
NC = "\033[0m"
# Directory Paths
ScriptDir = os.getcwd()
SubmitFileDir = ScriptDir + "/FilesForSubmit"
SubmittedFileDir = ScriptDir + "/FilesSubmitted"

# File Size Limiters
maxFileSize = 1024 * 1024 * 5 #this value equals 5mb as theres 1024 bites in a kb and 1024kb in a mb.

# Username and Password set the username and password
username = input(f"{GRN}Please chose a Username. {NC}") # sets the username for the account
password = input(f"{GRN}Please chose a Password. {NC}") # sets the Password for the account
print(f"Username: {username} | Password: {password}")
attempts = 3 # Attempts before account locking
print(attempts)

# Time Stamp
time = datetime.now()

# Timer Var
Ts = 0 # Timer Start
Tf = 0 # Timer Finish
maxTime = 60 # Maximum time you have to wait for account to be unlocked

# Log Files
def logFile(event): # Login Log
	log = "Login_log.txt"

	with open(log, "a") as f:
		f.write(f"Event: {event} TimeStamp: {time} \n")

def SubLogFile(event): # Submission Log
        log = "Submission_log.txt"

        with open(log, "a") as f:
                f.write(f"Event: {event} TimeStamp: {time} \n")


# Option Scripts.
def submitFile():
	# filePath = "/home/kali/Documents/AdvOp-Ass-1/Task-3/Python/FilesForSubmit/submit_docx.docx"
	filePath = input(f"{GRN}specify the path to your file.{NC} ")
	
	# Check File Exists
	if os.path.isfile(filePath):
		# Check the File type is accepted
		file = os.path.basename(filePath) # File name from file path
		fileExt = os.path.splitext(file)[1]  # Extension of the file

		if (fileExt == ".pdf" or fileExt == ".docx"):
			# Check if the file size is below 5MB
			fileSize = os.path.getsize(filePath) # Stored the files current size in bytes
			
			if (fileSize <= maxFileSize):
				# Check if the file has already been submitted
				filePathSubmitted = SubmittedFileDir +"/"+ file

				if not os.path.isfile(filePathSubmitted): # if the does NOT exist, copy the source over
					shutil.copyfile(filePath,filePathSubmitted) # Copies the file from point A to point B
					print(f"{GRN}File {file} has been submitted!{NC}")
					SubLogFile(f"StudID:{username} has uploaded {file} Successfully")
				else:
					# Failure File too Large
					SubLogFile(f"StudID:{username} tried uploading a file, but it was already submitted.")
					print(f"{RED}Assignment has already been submitted.{NC}")

			else:
				# Failure File too Large
				SubLogFile(f"StudID:{username} tried uploading a file, but it was too large..")
				print(f"{RED}File too large (max file size 5mb).{NC}")
		else:
			# Failure Wrong File type.
			SubLogFile(f"StudID:{username} tried uploading a file, but it wasn't an accepted file type.")
			print(f"{RED}File type unaccepted (Only .pdf and.docx accepted).{NC}")
	else:
		# Failure File doesnt exist
		SubLogFile(f"StudID:{username} tried uploading a file, but it didn't exist.")
		print(f"{RED}File does not exist in this file path.{NC}")

def checkFile(): # TBH Recycled code from submit() as it requires similar concept
	#filePath = "/home/kali/Documents/AdvOp-Ass-1/Task-3/Python/FilesForSubmit/submit_docx.docx"
	filePath = input(f"{GRN}specify the path to your file.{NC} ")
        
        # Check File Exists
	if os.path.isfile(filePath):
		# get file name from the file path
		file = os.path.basename(filePath) # File name from file path
		# combined submitted folder dir with file name
		filePathSubmitted = SubmittedFileDir +"/"+ file

		if os.path.isfile(filePathSubmitted): # if the does exist.
			print(f"{GRN}File {file} has been submitted!{NC}")
		else:
			# file has been submitted
			print(f"{RED}Assignment hasn't been submitted yet.{NC}")
	else:
		print(f"{RED}File selected doesnt exist.{NC}")
	

def viewSubmitted():
	# get all files in the submitted Folder into a list subfiles
	subfiles = os.listdir(SubmittedFileDir)
	
	print(f"{GRN}All Submitted Files.{NC}")
	print(f"============")
	
	# filters out all the folders so only the files are shown
	subfiles = [f for f in subfiles if os.path.isfile(SubmittedFileDir + "/" + f)]
	
	# Print out the results
	print(f"{GRN}")
	print(*subfiles, sep="\n") # Lists out all the items in the array with \n to add a new line
	print(f"{NC}\n============")

def login():
	# Get User Input
	user = input(f"{GRN}Enter your username: {NC}")
	pasw = input(f"{GRN}Enter your password: {NC}")

	global attempts # This ensures that we are using the global variable attempts instead of a local one
	global ts 
	global tf

	if (attempts > 0):
		# If no attempts are left you are unable to login
		if (user == username and pasw == password):
			# A Successful Login
			print(f"\n{GRN}Congradulations, Your'e in!{NC}")
			logFile(f"{username} Successfully Logged In") # Log Successful attempt
		else:
			# A unsuccessful Login
			attempts -= 1
			print(f"\n{RED}Incorrect username or password. \nPlease try again. {attempts} Attempts remaining{NC}")
			logFile(f"Unsuccessful Login attempt detected.") # Lock Unsuccessful attempt
			ts = T.time() # The Starting time when the accoutn gets locked
			print(ts)
	else:
		tf = T.time() # the finsihing time
		te = round(tf - ts) # Time Elipsed since account locked
		if (te >= maxTime): # if Time elipsed is greater then the Max time set then reset the attempts
			attempts = 3
		else: # Else print account locked message and make a log of suspicious activity
			print(f"{RED}Account Locked Please try again in {maxTime-te}sec.{NC}")
			logFile(f"Suspicious Login Pattern detected.")
# Exit the Program
def exitBye():
	# Gets Player Input for program closing confirmation.
	option = input(f"{GRN}Exit the program? Y/N: ")
	print(f"{NC}")

	match option:
		case "y" | "Y": # If you type Y or y exit the program.
			sys.exit()
		case _: # If any other input exit back into the program.
			print(f"")

def createFiles():
       	# Creates Submitted Files and files for submission
	try: # Create directory for files for submission for Testing, Uses Try so it doesnt crash when the dir exists
		os.mkdir(SubmitFileDir)
		print(f"{GRN}Test files and Dir Created{NC}")
	except FileExistsError:
		print("")

	try: # Creates the Siubmitted folder.
		os.mkdir(SubmittedFileDir)
		print(f"{GRN}Test files and Dir Created{NC}")
	except FileExistsError:
		print("")

        # Creates the required files if they dont exist
        
	open(SubmitFileDir + "/submit_txt.txt", "a") # Test txt
	open(SubmitFileDir + "/submit_docx.docx", "a") # Test docx
	open(SubmitFileDir + "/submit_pdf.pdf", "a") # Test pdf
	with open(SubmitFileDir + "/submit_lrg_pdf.pdf", "w") as f: # Test Large PDF
		charnum = 1024 * 1024 * 10 #creates a file that is 10MB in size
		f.write("0" * charnum)

def menuDraw():  
        print(f"{YLW}============{NC}")
        print(f"{YLW}CCCU Assignment Submission program{NC}")
        print(f"{YLW}============{NC}")
        print(f"{YLW}1. Submit an assignment.{NC}")
        print(f"{YLW}2. Check Submitted File.{NC}")
        print(f"{YLW}3. View All Submissions.{NC}")
        print(f"{YLW}4. Login.{NC}")
        print(f"{YLW}5. Exit Scheduler.{NC}")
        print(f"{YLW}============{NC}")

def mainLoop():
	# Variable set up.
	# Create Directories and Test files
	createFiles()

	print("Script Directory: " + ScriptDir)
	
	while True: # A Perpetuial While loop for keeping the programm running.
		# Draw the Main Menu.
		menuDraw()
	
		# Ask User for Menu Option and case.
		option = input(f"{GRN}Please Select an option 1 - 5: ")
		print(f"{NC}")
		
		# Options Avalible.
		match option:
			case "1":
				submitFile()
			case "2":
				checkFile()
			case "3":
				viewSubmitted()
			case "4":
				login()
			case "5":
				exitBye()
			case "x": #to exit out of the program without a confirmation
				break
			case _:
				print(f"{RED}That is not an option: {NC}")

mainLoop()

