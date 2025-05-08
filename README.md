# User Account Creation Script

This Bash script automates the process of creating user accounts on a Linux system. It allows administrators to create multiple user accounts based on input from a CSV file, assign temporary passwords, and send account details via email to each user. The script also logs all actions and reports any errors or warnings.

## Features

- **Automated User Creation**: Create multiple users from a CSV file containing their details.
- **Temporary Password**: Each user is assigned a default temporary password (`Amalitech123`), which they must change upon their first login.
- **Group Management**: Users are added to specified groups (if the group doesn't exist, it is created automatically).
- **Email Notifications**: Send account credentials (username and password) to each user via email.
- **Activity Logging**: Log all operations (successful and failed user creation, email sending, warnings, and errors).

## Prerequisites

Before running the script, ensure that the following prerequisites are met:

- **Mail Utility**: The script requires a mail utility to send emails. Install `mailutils` by running:
  - On Debian/Ubuntu: `sudo apt install mailutils`
- **Root Privileges**: The script must be run with root privileges to create user accounts and modify system files.
- **CSV File**: The input data for user creation must be in a CSV file or an everyday .txt file, with the following format:

```

username, Full Name, group, email@example.com

```

## Usage Instructions

### 1. Clone the Repository

Clone this repository to your local machine:

```bash
git clone https://github.com/Delvin-Yamoah/Bash-Scripting-Challenge-Lab.git
cd Bash-Scripting-Challenge-Lab
```

### 2. Make the Script Executable

Ensure the script is executable by running:

```bash
chmod +x your_script.sh
```

### 3. Prepare the User CSV File

Prepare a CSV file (e.g., `users.csv`) with the following structure:

```
username1, Full Name 1, group1, email1@example.com
username2, Full Name 2, group2, email2@example.com
```

### 4. Run the Script

Execute the script with the path to the CSV file as an argument:

```bash
sudo ./your_script.sh /path/to/users.csv
```

The script will:

- Create each user in the CSV file with a temporary password (`Amalitech123`).
- Send an email with the user's account credentials.
- Log all actions and events to the `iam_setup.log` file.

## Log File

The script logs detailed information about the user creation process in the `iam_setup.log` file. This log includes:

- **User Creation Events**: Records whether user creation was successful or failed.
- **Email Notifications**: Tracks whether email notifications were successfully sent or failed.
- **Warnings and Errors**: Logs any issues, such as missing groups or existing users.

## Troubleshooting

Here are some common issues you might encounter while running the script:

- **No Email Sent**: If the email was not sent, ensure that `mailutils` is properly configured and that your system is able to send outgoing emails.
- **Permission Issues**: Make sure the script is executed with root privileges (`sudo`) to avoid permission errors when creating users or modifying system files.
- **Incorrect CSV Format**: The script expects the CSV file to be formatted correctly, with no header and fields in the correct order: `username, full name, group, email`.
