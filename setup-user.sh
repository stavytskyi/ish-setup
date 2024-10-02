#!/bin/sh

# Script to create a non-root user with zsh and privileged rights using doas
# The user is created without a password

# Exit immediately if a command exits with a non-zero status
set -e

# Function to check if a package is installed
is_installed() {
    apk info -e "$1" >/dev/null 2>&1
}

# Function to install a package if not already installed
install_package() {
    PACKAGE_NAME="$1"
    if is_installed "$PACKAGE_NAME"; then
        echo "Package '$PACKAGE_NAME' is already installed. Skipping installation."
    else
        echo "Installing package '$PACKAGE_NAME'..."
        apk add --no-cache "$PACKAGE_NAME"
        echo "Package '$PACKAGE_NAME' installed successfully."
    fi
}

# Function to create a new user
create_user() {
    USERNAME="$1"
    HOME_DIR="/home/$USERNAME"
    SHELL="/bin/zsh"

    if id "$USERNAME" >/dev/null 2>&1; then
        echo "User '$USERNAME' already exists. Skipping creation."
    else
        echo "Creating user '$USERNAME' with shell $SHELL..."
        adduser "$USERNAME" -D -h "$HOME_DIR" -s "$SHELL"
        echo "User '$USERNAME' created successfully without a password."
    fi
}

# Function to add user to wheel group
add_to_wheel() {
    USERNAME="$1"
    GROUP="wheel"

    if id -nG "$USERNAME" | grep -qw "$GROUP"; then
        echo "User '$USERNAME' is already a member of group '$GROUP'. Skipping."
    else
        echo "Adding user '$USERNAME' to group '$GROUP'..."
        addgroup "$USERNAME" "$GROUP"
        echo "User '$USERNAME' added to group '$GROUP'."
    fi
}

# Function to configure doas
configure_doas() {
    USERNAME="$1"
    DOAS_CONF="/etc/doas.conf"
    RULE_GROUP="permit persist :wheel"
    RULE_USER="permit nopass $USERNAME as root"

    # Uncomment the rule for group wheel if commented
    if grep -q "^# permit persist :wheel" "$DOAS_CONF"; then
        echo "Uncommenting rule for group 'wheel' in $DOAS_CONF..."
        sed -i "/^# permit persist :wheel/s/^# //" "$DOAS_CONF"
        echo "Rule uncommented."
    elif ! grep -Fxq "$RULE_GROUP" "$DOAS_CONF"; then
        echo "Adding rule for group 'wheel' to $DOAS_CONF..."
        echo "$RULE_GROUP" >> "$DOAS_CONF"
        echo "Rule added."
    else
        echo "Rule for group 'wheel' already exists. Skipping."
    fi

    # Add permit rule for the user without password
    if grep -Fxq "$RULE_USER" "$DOAS_CONF"; then
        echo "Rule for user '$USERNAME' already exists. Skipping."
    else
        echo "Adding rule for user '$USERNAME' to $DOAS_CONF..."
        echo "$RULE_USER" >> "$DOAS_CONF"
        echo "Rule added."
    fi

    # Set proper permissions for doas.conf
    chmod 600 "$DOAS_CONF"
    echo "Permissions for $DOAS_CONF set to 600."
}

# Main function
main() {
    # Prompt for the new username
    read -p "Enter the new username: " NEW_USER

    # Validate input
    if [ -z "$NEW_USER" ]; then
        echo "Error: Username cannot be empty. Exiting."
        exit 1
    fi

    # Update and upgrade packages
    echo "Updating and upgrading packages..."
    apk update && apk upgrade
    echo "Packages updated and upgraded."

    # Install necessary packages
    install_package "zsh"
    install_package "doas"

    # Create the new user
    create_user "$NEW_USER"

    # Add the user to the wheel group
    add_to_wheel "$NEW_USER"

    # Configure doas
    configure_doas "$NEW_USER"
    
    echo "Setup complete!"
	echo ""
	echo "To switch to user '$NEW_USER', use the following command:"
	echo "  su - $NEW_USER"
	echo ""
	echo "Additionally, to set '$NEW_USER' as the default login user in iSH, follow these steps:"
	echo "1. Tap and hold the gear icon on the on-screen keyboard for 10 seconds to access advanced settings."
	echo "2. Change the 'Launch cmd' from '/bin/login -f root' to '/bin/login -f NEW_USER'."
	echo "3. Save the changes and restart the iSH app."
}

# Execute the main function
main
