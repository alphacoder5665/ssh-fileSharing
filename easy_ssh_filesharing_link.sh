#!/bin/bash

# 📝 This is the main config file to save user credentials
CONFIG_FILE="$HOME/.fileshare_config"

# 📂 This is the config file to save file and folder paths
CONFIG_FILE_PATH="$HOME/.fileshare_paths_config"

# 📋 Function to show the menu to the user
function display_menu() {
    clear                              # 🧹 Clear the terminal screen
    echo "( + ) Filesharing Menu List" # 🗂️ Display menu title
    echo "--------------------------------------------"
    echo "[ 1 ] Copy from server(Termux) terminal" # ➡️ Option to copy from Termux to WSL
    echo ""
    echo "[ 2 ] Copy from client(Windows WSL) terminal" # ⬅️ Option to copy from WSL to Termux
    echo ""
    echo "[ 3 ] Use saved previous user details" # 💾 Use saved config
    echo ""
    echo "[ - ] Exit" # ❌ Exit option
    echo ""
    read -p "Enter Choice: " choice # 🎮 Get user input for choice
}

# 📤 Function to ask for user credentials and paths
function ask_data() {
    clear # 🧹 Clear the terminal
    echo ""
    read -p "Enter Username/(whoami) id >> " username # 🙋 Ask username
    echo ""
    read -p "Enter IP address (ifconfig)/(ipconfig) in cmd of client >> " ipAddress # 🌐 Ask IP
    echo ""
    read -p "Enter port number (e.g.: 8022) >> " portNumber # 🚪 Ask port number
    echo ""
    read -p "Enter Path of file to copy >> " filePath # 📄 Ask file path
    echo ""
    read -p "Enter Path of folder to paste >> " folderPath # 📁 Ask folder path
    echo ""

    read -p "Do you want to save these user details (username, IP, port) for later? (y/n): " save_choice
    if [[ "$save_choice" =~ ^[Yy]$ ]]; then
        save_user_details "$username" "$ipAddress" "$portNumber" # 💾 Save login info
    fi

    read -p "Do you also want to save filePath and folderPath for later? (y/n): " user_choice
    if [[ "$user_choice" =~ ^[Yy]$ ]]; then
        save_user_paths "$filePath" "$folderPath" # 💾 Save paths
    fi
}

# 🚧 Previously commented function block
# function ask_paths_only() {
#     ## load here "load_user_paths"
#     # clear
#     load_user_paths
#     printf "\n\n"
#     echo "Using saved user details."
#     echo ""
#     read -p "Enter Path of file to copy >> " filePath
#     echo ""
#     read -p "Enter Path of folder to paste >> " folderPath
#     echo ""
# }

# 📥 Function to ask only for file/folder paths
function ask_paths_only() {
    load_user_paths # 📂 Load saved paths

    printf "\n\n"
    echo "Using saved user details."
    echo ""

    local new_filePath   # 🧾 Local variable to store file path
    local new_folderPath # 📦 Local variable to store folder path

    # ✏️ Ask with pre-filled default path
    read -p "Enter Path of file to copy >> " -e -i "${showFilePath}" new_filePath
    filePath="$new_filePath"

    # filePath="$(echo "$filePath" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')" # 🧽 Trim spaces

    echo ""

    # 📂 Ask for folder path with editable default
    read -p "Enter Path of folder to paste >> " -e -i "${showFolderPath}" new_folderPath
    folderPath="$new_folderPath"

    # folderPath="$(echo "$folderPath" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')" # 🧽 Trim spaces

    echo ""

    # ❗Check if inputs are empty
    if [[ -z "$filePath" || -z "$folderPath" ]]; then
        echo "Error: File or folder path cannot be empty."
        return 1 # ❌ Error code
    else
        return 0 # ✅ Success
    fi
}

# 💾 Save user credentials
function save_user_details() {
    local saved_username="$1"
    local saved_ipAddress="$2"
    local saved_portNumber="$3"

    echo "Saving details to $CONFIG_FILE..."

    # 📦 Save into config file
    cat >"$CONFIG_FILE" <<EOL
username=$saved_username
ipAddress=$saved_ipAddress
portNumber=$saved_portNumber
EOL

    if [[ $? -eq 0 ]]; then
        echo "Details saved successfully."
    else
        echo "Error: Could not save details to $CONFIG_FILE."
    fi
    echo ""
}

# 🔍 Load user credentials from config
function load_user_details() {
    echo "Attempting to load details from $CONFIG_FILE..."
    if [[ -f "$CONFIG_FILE" ]]; then
        source "$CONFIG_FILE" # 📂 Load variables
        if [[ -n "$username" && -n "$ipAddress" && -n "$portNumber" ]]; then
            echo "Details loaded successfully."
            echo "Username: $username"
            echo "IP Address: $ipAddress"
            echo "Port Number: $portNumber"
            echo ""
            return 0 # ✅ Success
        else
            echo "Error: Saved configuration file is incomplete or corrupted."
            echo "Please use option 1 or 2 to enter details and save them."
            echo ""
            return 1 # ❌ Failure
        fi
    else
        echo "No saved details found at $CONFIG_FILE."
        echo "Please use option 1 or 2 to enter details and save them first."
        echo ""
        return 1 # ❌ Failure
    fi
}

# 💾 Save file/folder paths
function save_user_paths() {
    local saved_filePath="$1"
    local saved_folderPath="$2"

    echo "Saving details to $CONFIG_FILE_PATH..."

    cat >"$CONFIG_FILE_PATH" <<EOL
showFilePath="$saved_filePath "
showFolderPath="$saved_folderPath "
EOL

    if [[ $? -eq 0 ]]; then
        echo "Paths saved successfully."
    else
        echo "Error: Could not save paths to $CONFIG_FILE_PATH."
    fi
    echo ""
}

# 🔍 Load file/folder paths
function load_user_paths() {
    echo "Attempting to load paths from $CONFIG_FILE_PATH..."
    if [[ -f "$CONFIG_FILE_PATH" ]]; then
        source "$CONFIG_FILE_PATH" # 📂 Load variables
        if [[ -n "$showFilePath" && -n "$showFolderPath" ]]; then
            echo "Paths loaded successfully."
            echo "File Path: $showFilePath"
            echo "Folser Path: $showFolderPath"
            echo ""
        else
            echo "Error: Saved configuration file is incomplete or corrupted."
            echo "Please use option 1 or 2 or 3 to enter details and save them."
            echo ""
            return 1 # ❌ Failure
        fi
    else
        echo "No saved paths found at $CONFIG_FILE_PATH."
        echo "Please use option 1 or 2 or 3 to enter details and save them first."
        echo ""
        return 1 # ❌ Failure
    fi
}

# 🖥️ Show menu to user
display_menu

# 🛠️ Choose what to do based on user input
case $choice in
1)
    ask_data # 🔄 Ask for all info
    echo ""
    printf "\nIt asks for password. If you know it, proceed. If not, reset using 'passwd' in terminal.\n"
    read -p "Do you want to 'share folders' from server to client? (y/n): " save_fchoice
    if [[ "$save_fchoice" =~ ^[Yy]$ ]]; then
         scp -r -P "$portNumber" "$username@$ipAddress:$filePath" "$folderPath" # 🚚 Copy folder from server to client
    else
    	echo ""
    	scp -P "$portNumber" "$username@$ipAddress:$filePath" "$folderPath" # 🚚 Copy file from server to client
    fi
    ;;
2)
    ask_data # 🔄 Ask for all info
    echo ""
    printf "\nIt asks for password. If you know it, proceed. If not, reset using 'passwd' in terminal.\n"
    read -p "Do you want to 'share folders' from server to client? (y/n): " save_fchoice
    if [[ "$save_fchoice" =~ ^[Yy]$ ]]; then
         scp -r -P "$portNumber" "$filePath" "$username@$ipAddress:$folderPath" # 🚚 Copy folder from client to server
    else
        echo ""
        scp -P "$portNumber" "$filePath" "$username@$ipAddress:$folderPath" # 🚚 Copy file from client to server
    fi
    ;;
3)
    load_user_details # 🔁 Load credentials
    load_status=$?    # 💡 Store result of load

    if [[ $load_status -eq 0 ]]; then
        ask_paths_only # 🔁 Ask paths
        echo ""
        echo "It asks for password. If you know it, proceed. If not, reset using 'passwd' in terminal."
        echo ""
        printf "(+) Copy direction: \n\t[1] Server(Termux) to Client(Windows WSL), \n\t[2] Client(Windows WSL) to Server(Termux)?\n"
        read copy_direction_choice # 🔀 Ask copy direction

        case $copy_direction_choice in
        1)
            printf "\nIt asks for password. If you know it, proceed. If not, reset using 'passwd' in terminal.\n"
    	    read -p "Do you want to 'share folders' from server to client? (y/n): " save_fchoice
    	    if [[ "$save_fchoice" =~ ^[Yy]$ ]]; then
         	scp -r -P "$portNumber" "$username@$ipAddress:$filePath" "$folderPath" # 🚚 Copy folder from server to client
            else
        	echo ""
        	scp -P "$portNumber" "$username@$ipAddress:$filePath" "$folderPath" # 🚚 Copy file from server to client
    	    fi
            ;;
        2)
            printf "\nIt asks for password. If you know it, proceed. If not, reset using 'passwd' in terminal.\n"
            read -p "Do you want to 'share folders' from server to client? (y/n): " save_fchoice
    	    if [[ "$save_fchoice" =~ ^[Yy]$ ]]; then
         	scp -r -P "$portNumber" "$filePath" "$username@$ipAddress:$folderPath" # 🚚 Copy folder from client to server
    	    else
        	echo ""
        	scp -P "$portNumber" "$filePath" "$username@$ipAddress:$folderPath" # 🚚 Copy file from client to server
    	    fi
            ;;
        *)
            echo "Invalid direction choice. Aborting copy."
            exit 1 # ❌ Exit on invalid input
            ;;
        esac
    else
        exit 1 # ❌ Exit if loading fails
    fi
    ;;
-)
    exit 1 # ❌ Exit
    ;;
*)
    echo "Invalid choice. Exiting."
    exit 1 # ❌ Exit
    ;;
esac

exit 0 # ✅ All done!
