#!/bin/sh

#For Server Owners
export MIN_RAM="1G"
export MAX_RAM="5G"
export FORGE_JAR="forge.jar"
#Number of times the server should crash in a hour before it stops
export CRASH_COUNT=10

#For Modpack Developers
export MCVER="1.11.2"
export LAUNCHWRAPPERVERSION="1.12"

#For Script Developers
export JARFILE="minecraft_server.${MCVER}.jar"
export LAUNCHWRAPPER="net/minecraft/launchwrapper/${LAUNCHWRAPPERVERSION}/launchwrapper-${LAUNCHWRAPPERVERSION}.jar"

install_server(){
    mkdir -p $(dirname libraries/${LAUNCHWRAPPER})
    
    which wget
    if [ $? -eq 0 ]; then
        wget -O ${JARFILE} https://s3.amazonaws.com/Minecraft.Download/versions/${MCVER}/${JARFILE}
        wget -O libraries/${LAUNCHWRAPPER} https://libraries.minecraft.net/${LAUNCHWRAPPER}
    else
        which curl
        if [ $? -eq 0 ]; then
                curl -o ${JARFILE} https://s3.amazonaws.com/Minecraft.Download/versions/${MCVER}/minecraft_server.${MCVER}.jar
        		curl -o libraries/${LAUNCHWRAPPER} https://libraries.minecraft.net/${LAUNCHWRAPPER}
        else
                echo "Neither wget or curl were found on your system. Please install one and try again"
        fi
    fi
}

start_server() {
    echo "Starting server"
    java -Xms${MIN_RAM} -Xmx${MAX_RAM} -XX:+DisableExplicitGC -XX:+UseConcMarkSweepGC -XX:MaxTenuringThreshold=15 -XX:MaxGCPauseMillis=30 -XX:-UseGCOverheadLimit -XX:+UseBiasedLocking -XX:SurvivorRatio=8 -XX:TargetSurvivorRatio=90 -XX:+UseCompressedOops -XX:+OptimizeStringConcat -XX:+AggressiveOpts -XX:ReservedCodeCacheSize=2048m -XX:+UseCodeCacheFlushing -XX:SoftRefLRUPolicyMSPerMB=20000 -jar -server ${FORGE_JAR} nogui
}

if [ ! -f ${JARFILE} -o ! -f libraries/${LAUNCHWRAPPER} ]; then
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
        echo "Stopping Server..."
        exit 0
    fi
    echo "Press Ctrl+C before the time runs out to safely stop the server!"
    for i in 10 9 8 7 6 5 4 3 2 1; do
        echo "Restarting server in $i"
        sleep 1
    done
    echo "Rebooting now!"
done