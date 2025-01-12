#!/bin/bash

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "Please run this script as root or use sudo."
  exit 1
fi

# Define variables
USERNAME="jenkins_user"
PASSWORD="9849"

# Check if the user already exists
if id "$USERNAME" &>/dev/null; then
  echo "User $USERNAME already exists."
else
  # Create the user
  useradd "$USERNAME"
  if [ $? -eq 0 ]; then
    echo "User $USERNAME created successfully."
  else
    echo "Failed to create user $USERNAME."
    exit 1
  fi
fi

# Set the password for the user
echo "$PASSWORD" | passwd --stdin "$USERNAME" &>/dev/null
if [ $? -eq 0 ]; then
  echo "Password for user $USERNAME has been set successfully."
else
  echo "Failed to set the password for user $USERNAME."
  exit 1
fi

# Add the jenkins user to the sudoers file
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
  if [ $? -eq 0 ]; then
    echo "Successfully added $USERNAME to the sudoers file with no password requirement."
  else
    echo "Failed to modify the sudoers file."
    exit 1
  fi

# Switch to the jenkins user and create the .ssh directory
su - "$USERNAME" -c "
mkdir -p ~/.ssh &&
chmod 700 ~/.ssh &&
touch ~/.ssh/authorized_keys &&
chmod 600 ~/.ssh/authorized_keys &&
echo '.ssh directory and authorized_keys file created successfully.'
"

#Open port 8080 for jenkins 
firewall-cmd --add-port=8080/tcp --permanent
firewall-cmd --add-service=http --permanent
firewall-cmd --reload
firewall-cmd --list-ports


echo "Script execution completed successfully."
