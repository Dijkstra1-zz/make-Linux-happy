start_server() {
    echo "Starting server"
    java -Xmx7000m -XX:+DisableExplicitGC -XX:+UseConcMarkSweepGC -XX:MaxTenuringThreshold=15 -XX:MaxGCPauseMillis=30 -XX:-UseGCOverheadLimit -XX:+UseBiasedLocking -XX:SurvivorRatio=8 -XX:TargetSurvivorRatio=90 -XX:+UseCompressedOops -XX:+OptimizeStringConcat -XX:+AggressiveOpts -XX:ReservedCodeCacheSize=2048m -XX:+UseCodeCacheFlushing -XX:SoftRefLRUPolicyMSPerMB=20000 -jar -server forge.jar nogui
}

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
    
    if [ "$a" -eq "10" ]; then
        echo "The server has crashed to many times"
        exit 0
    fi
    echo "Press Ctrl+C before the time runs out to safely stop the server!"
    for i in 10 9 8 7 6 5 4 3 2 1; do
        echo "Restarting server in $i"
        sleep 1
    done
    echo "Rebooting now!"
done