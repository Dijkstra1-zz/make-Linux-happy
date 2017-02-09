#Script by Dijkstra
#!/bin/sh

#For Server Owners
export MIN_RAM="1G"
export MAX_RAM="5G"
export FORGE_JAR="forge.jar"
export JAVA_ARGS="-server -XX:+DisableExplicitGC -XX:+UseConcMarkSweepGC -XX:MaxTenuringThreshold=15 -XX:MaxGCPauseMillis=30 -XX:-UseGCOverheadLimit -XX:+UseBiasedLocking -XX:SurvivorRatio=8 -XX:TargetSurvivorRatio=90 -XX:+UseCompressedOops -XX:+OptimizeStringConcat -XX:+AggressiveOpts -XX:ReservedCodeCacheSize=2048m -XX:+UseCodeCacheFlushing -XX:SoftRefLRUPolicyMSPerMB=20000"
#Number of times the server should crash in a hour before it stops
export CRASH_COUNT=10
export RUN_FROM_BAD_FOLDER=0
export IGNORE_OFFLINE=0


#For Modpack Developers
export MCVER="1.11.2"
export FORGEVER="13.20.0.2226"
export FORGEURL="DISABLE"

install_server(){
    if [ -f installer.jar ]; then
		echo "Found Server Installer No need to download one"
    else
        if [ "${FORGEURL}" == "DISABLE" ]; then
            export URL="http://files.minecraftforge.net/maven/net/minecraftforge/forge/${MCVER}-${FORGEVER}/forge-${MCVER}-${FORGEVER}-installer.jar"
        else
            export URL="${FORGEURL}"
        fi
        which wget
        if [ $? -eq 0 ]; then
            wget -O installer.jar "${URL}"
        else
            which curl
            if [ $? -eq 0 ]; then
				curl -o installer.jar "${URL}"
            else
                echo "Neither wget or curl were found on your system. Please install one and try again"
            fi
        fi
    fi
    
	if [ ! -f installer.jar ]; then
		echo "Server not installed"
		exit 0
	else
		echo "Installing Server"
		java -jar installer.jar --installServer
		echo "Deleting installer"
		rm installer.jar
		rm installer.jar.log
		echo "Setting jar name"
		mv "forge-${MCVER}-${FORGEVER}-universal.jar" ${FORGE_JAR}
	fi
}

start_server() {
    echo "Starting server"
    java -Xms${MIN_RAM} -Xmx${MAX_RAM} ${JAVA_ARGS} -jar ${FORGE_JAR} nogui
}

check_if_temp(){
    echo "$(pwd)"
    if [ "$(pwd)" == "/tmp" ] || [ "$(pwd)" == "/var/tmp" ]; then
        echo "Should not be run from temp"
        if [ ${RUN_FROM_BAD_FOLDER} -eq 0 ]; then
            echo "@Ordinator Erro mesaage here :P"
            exit 0
        else
            echo "bad choice message"
        fi
    fi
}

check_dir(){
    if [ ! -r . ] || [ ! -w . ]; then 
        echo "You do not have full access to folder"
        if [ ${RUN_FROM_BAD_FOLDER} -eq 0 ]; then
            echo "@Ordinator Error mesaage here :P"
            exit 0
        else
            echo "Bad choice  message"
        fi
    fi
}

check_connection(){
    
    if ping -c 1 allthepacks.com >> /dev/null 2>&1; then
        echo "Wow internet connection"
    else
        echo "Failed frist lets try another one Pls changes these bad messages @Ordinator"

        if ping -c 1 google.com >> /dev/null 2>&1; then
            echo "Wow internet connection"
        else
            if [ ${IGNORE_OFFLINE} -eq 0 ]; then
                echo "@Ordinator Error mesaage here :P"
                exit 0
            else
                echo "Bad choice  message"
            fi
        fi  
    fi
}

check_if_temp
check_dir
check_connection

if [ ! -f ${FORGE_JAR} ]; then
    echo "Installing required jars."
    install_server
fi

a=0
last_crash=$((SECONDS))

while true ; do
    start_server
    b=$?

    if [ "$b" -eq "0" ]; then
	    a=0
    else
        now=$((SECONDS))
        diff=$(($now-$last_crash))
        if [ "$diff" -gt "3600" ]; then
            a=1
            else
            a=$((a+1))
        fi
        last_crash=$((SECONDS))
        
    fi
    
    if [ "$a" -eq ${CRASH_COUNT} ]; then
        echo "The server has crashed to many times"
        exit 0
    fi
    if [ ! -f auto_restart ]; then
        echo "Stopping Server"
        exit 0
    fi
    echo "Press Ctrl+C before the time runs out to safely stop the server!"
    for i in 10 9 8 7 6 5 4 3 2 1; do
        echo "Restarting server in $i"
        sleep 1
    done
    echo "Rebooting now!"
done
