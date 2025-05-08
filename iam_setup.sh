#!/bin/bash

set -x  # Add this line at the beginning for debugging

PASSWORD_FILE="/root/user_passwords.txt"
LOG_FILE="$(dirname "$0")/iam_setup.log"
EMAIL_SUBJECT="Your New User Account Credentials"
USERS_FILE="$1"

# Allowing only root to access the script
if [ "$(id -u)" -ne 0 ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: This script must be run as root" | tee -a "$LOG_FILE"
    exit 1
fi

# Initialize log file
touch "$LOG_FILE"
chmod 644 "$LOG_FILE"
echo "=== USER CREATION LOG - $(date '+%Y-%m-%d %H:%M:%S') ===" >> "$LOG_FILE"

# Initialize password file
touch "$PASSWORD_FILE"
chmod 600 "$PASSWORD_FILE"

# Check for mail command
if ! command -v mail &> /dev/null; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: 'mail' command not found. Install with: sudo apt install mailutils. It comes with Postfix." | tee -a "$LOG_FILE"
    exit 1
fi

# Check if users file exists
if [ ! -f "$USERS_FILE" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: Users file $USERS_FILE not found" | tee -a "$LOG_FILE"
    exit 1
fi

# Setting up password complexity
is_password_complex() {
    local pwd="$1"
    [[ ${#pwd} -ge 8 ]] &&
    [[ "$pwd" =~ [A-Z] ]] &&
    [[ "$pwd" =~ [a-z] ]] &&
    [[ "$pwd" =~ [0-9] ]] 
}

# User creation function
create_user_with_email() {
    local username="$1"
    local fullname="$2"
    local group="$3"
    local user_email="$4"

    # Set the temporary password to 'Amalitech123'
    temp_password="Amalitech123"

    # Check if user exists
    if id "$username" &>/dev/null; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARNING: User $username already exists. Skipping." | tee -a "$LOG_FILE"
        return 1
    fi

    # Creating user
    if ! useradd -s /bin/bash -m -d "/home/$username" -c "$fullname" "$username"; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: Failed to create user $username" | tee -a "$LOG_FILE"
        return 1
    fi

    # Setting password
    if ! echo "$username:$temp_password" | chpasswd; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: Failed to set password for $username" | tee -a "$LOG_FILE"
        userdel -r "$username" 2>/dev/null
        return 1
    fi

    # Force password change
    chage -d 0 "$username"

    # Group management
    if getent group "$group" >/dev/null; then
        usermod -aG "$group" "$username"
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARNING: Group $group does not exist, skipping user addition to group." | tee -a "$LOG_FILE"
    fi

    # Logging credentials securely
    echo "$username:$temp_password" >> "$PASSWORD_FILE"

    # Email notification
    local message="Hello $fullname,
Your new User account has been created:
Username: $username
Temporary Password: $temp_password
Group: $group
You must change your password at first login.
Regards,
Amalitech"
    if echo "$message" | mail -s "$EMAIL_SUBJECT" "$user_email"; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] SUCCESS: Created $username. Email sent to $user_email" | tee -a "$LOG_FILE"
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARNING: Created $username but failed to send email to $user_email" | tee -a "$LOG_FILE"
    fi
}

# Main execution
echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: Starting user creation from $USERS_FILE" | tee -a "$LOG_FILE"
tail -n +2 "$USERS_FILE" | while IFS=, read -r username fullname group email; do
    if [[ -z "$username" || -z "$fullname" || -z "$group" || -z "$email" ]]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] SKIPPING: Incomplete user entry." | tee -a "$LOG_FILE"
        continue
    fi
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] PROCESSING: Creating $username ($fullname)" | tee -a "$LOG_FILE"
    create_user_with_email "$username" "$fullname" "$group" "$email"
done

echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: User creation completed. Log saved to $LOG_FILE" | tee -a "$LOG_FILE"
