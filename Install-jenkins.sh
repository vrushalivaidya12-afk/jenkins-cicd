#!/bin/bash

set -e
LOGFILE="jenkins-install.log"

log() {
    echo -e "\n[$(date)] $1" | tee -a $LOGFILE
}

check_root() {
    if [ "$UID" -ne 0 ]; then
        echo "You Need to be ROOT user First"
        exit 1
    fi
}

check_internet() {
    if ! ping -c 1 google.com &>/dev/null; then
        log "ERROR: No internet connectivity"
        exit 1
    fi
}

install_dependancy() {

    log "\n Updateting the library ..."
    apt update -y
    if command -v java &>/dev/null; then
        version=$(java --version 2>&1)
        echo "$version"
    fi

    log "\n Installing openjdk-21.jre..."
    apt install fontconfig openjdk-21-jre -y

    log "\n Checking the Installation results.."
    java_version=$(java -version 2>&1 | grep -oP 'version "\K[0-9._]+')
    if [ -n "$java_version" ]; then
        log "Java Version: ${java_version}"
    else
        log "Fail to install"
        exit 1
    fi
}

install_jenkins(){
    
    check_root
    
    log "Installing Jenkins Server now ..." 
    log "checking pre-requesite..."
    
    install_dependancy
    
    log "........."
    wget -O /etc/apt/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key 
    echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
    apt update -y
    apt install jenkins -y

    log "Installation completed...."
    log "Starting the Jenkins Service now.."

    systemctl start jenkins

    log "Installation Status..."

    systemctl status jenkins

}

while true 
do
    log "_______________________________"
    log "1. Install Dependancy"
    log "3. Exit"
    log "_______________________________"
    
    read -p "\n Enter your choice:" option

    case $option in

    1) install_dependancy ;;
    2) install_jenkins ;;
    *) echo "Invalid option" ;;
    
    esac

done

 