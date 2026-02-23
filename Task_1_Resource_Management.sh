
#Setting up base directories and file names
BASE_DIR="$HOME/AssignmentDirectory"
ARCHIVE_DIR="$BASE_DIR/ArchiveLogs"
LOG_FILE="BASE_DIR/System_Monitor_Log.txt"
WARNING_LIMIT_MB=500

#Seting up the Admin Log function
log_event(){
local msg="$1"
printf"%s %s\n" "$(date'+%Y-%m-%d %H:%M:%S')" "$msg" >> "$LOG_FILE"
}
