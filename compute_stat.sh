#!/bin/bash
FILE=$1
NBEXT=4 # NB - 1
FILAMENT_LENGTH=$2

echo "---------------------------------------------"
echo "                    SWAP                     "
echo "---------------------------------------------"
echo  "Nb swap : $(cat $FILE  | grep "TX:1" | wc -l)"
for i in $(seq 0 $NBEXT)
do
	echo -e "T$i load/unload : $(cat $FILE  | grep "LT:1:T$i" | wc -l) \t/ $(cat $FILE  | grep "UT:1:T$i" | wc -l)"
done


echo "---------------------------------------------"
echo "                    TIME                     "
echo " average time load/unload/pause/purge/purge length    "
echo "---------------------------------------------"
TOTAL_TX_TIME=0
NB_TX=0
TOTAL_LOAD_TIME=0
TOTAL_UNLOAD_TIME=0
TOTAL_PURGE_TIME=0
TOTAL_PURGE_LENGTH=0
TOTAL_PAUSE_TIME=0
for i in $(seq 0 $NBEXT)
do
	TOTAL_LOAD_T=0
	NB_LOAD_T=0
	TOTAL_UNLOAD_T=0
	NB_UNLOAD_T=0
	TOTAL_PAUSE_T=0
	NB_PAUSE_T=0
	TOTAL_PURGE_T=0
	NB_PURGE_T=0
	TOTAL_PURGE_LENGTH_T=0
	IGNORE=0
	cat $FILE | grep "T$i" > /tmp/mmu_stat_temp
	while read line
	do
		TIME=$(echo $line | cut -d":" -f1)
		CMD=$(echo $line | cut -d":" -f2)
		STATUS=$(echo $line | cut -d":" -f3)
		if [ $CMD == "LT" ]; then
			if [ $STATUS -eq 0 ]; then 
				ST=$TIME
			fi
			if [ $STATUS -eq 1 -a $IGNORE -eq 0 ]; then 
				ET=$TIME
				LT=$(($ET - $ST))
				TOTAL_LOAD_TIME=$(($TOTAL_LOAD_TIME + $LT))
				TOTAL_LOAD_T=$(($TOTAL_LOAD_T + $LT))
				NB_LOAD_T=$(($NB_LOAD_T + 1))
			fi
		elif [ $CMD == "UT" ]; then
	                TIME=$(echo $line | cut -d":" -f1)
        	        STATUS=$(echo $line | cut -d":" -f3)
                	if [ $STATUS -eq 0 ]; then ST=$TIME;fi
	                if [ $STATUS -eq 1 -a $IGNORE -eq 0 ]; then
        	                ET=$TIME
                	        LT=$(($ET - $ST))
                        	TOTAL_UNLOAD_TIME=$(($TOTAL_UNLOAD_TIME + $LT))
	                        TOTAL_UNLOAD_T=$(($TOTAL_UNLOAD_T + $LT))
        	                NB_UNLOAD_T=$(($NB_UNLOAD_T + 1))
                	fi
		elif [ $CMD == "PU" ]; then
	                TIME=$(echo $line | cut -d":" -f1)
        	        STATUS=$(echo $line | cut -d":" -f3)
			if [ $STATUS -eq 0 ]; then PUS=$TIME;fi
	                if [ $STATUS -eq 1 -a $IGNORE -eq 0 ]; then
        	                PUE=$TIME
                	        PUT=$(($PUE - $PUS))
                        	TOTAL_PURGE_TIME=$(($TOTAL_PURGE_TIME + $PUT))
	                        TOTAL_PURGE_T=$(($TOTAL_PURGE_T + $PUT))
        	                NB_PURGE_T=$(($NB_PURGE_T + 1))
                	fi
			if [ $STATUS -gt 1 ]; then
				TOTAL_PURGE_LENGTH_T=$(($TOTAL_PURGE_LENGTH_T + $STATUS))
				TOTAL_PURGE_LENGTH=$(($TOTAL_PURGE_LENGTH + $STATUS))
			fi
		elif [ $CMD == "TX" ]; then
	                TIME=$(echo $line | cut -d":" -f1)
        	        STATUS=$(echo $line | cut -d":" -f3)
                	if [ $STATUS -eq 0 ]; then 
				STX=$TIME
				IGNORE=0
			fi
	                if [ $STATUS -eq 1 -a $IGNORE -eq 0 ]; then
        	                ETX=$TIME
                	        LTX=$(($ETX - $STX))
                        	TOTAL_TX_TIME=$(($TOTAL_TX_TIME + $LTX))
        	                NB_TX=$(($NB_TX + 1))
                	fi
		elif [ $CMD == "ERROR" ]; then
			IGNORE=1
			if [ $STATUS == "PAUSE" ]; then STP=$TIME;fi	
			if [ $STATUS == "RESUME" ]; then
                                ETP=$TIME
                                TP=$(($ETP - $STP))
                                TOTAL_PAUSE_TIME=$(($TOTAL_PAUSE_TIME + $TP))
                                TOTAL_PAUSE_T=$(($TOTAL_PAUSE_T + $TP))
                                NB_PAUSE_T=$(($NB_PAUSE_T + 1))
                        fi
		fi
	done < /tmp/mmu_stat_temp
	rm -f /tmp/mmu_stat_temp

	echo -en "T$i :\t"
	if [ $NB_LOAD_T -gt 0 ]; then 
		echo -n "$(($TOTAL_LOAD_T / $NB_LOAD_T))s"
	else echo -n "0"
	fi
	echo -ne " \t/ "
	if [ $NB_UNLOAD_T -gt 0 ]; then 
		echo -n "$((TOTAL_UNLOAD_T / $NB_UNLOAD_T))s"
	else echo -n "0"
	fi
	echo -ne " \t/ "
	if [ $NB_PAUSE_T -gt 0 ]; then 
		echo -n "$(($TOTAL_PAUSE_T / $NB_PAUSE_T))s"
	else echo -n "0"
	fi
	echo -ne " \t/ "
	if [ $NB_PURGE_T -gt 0 ]; then 
		echo -n "$(($TOTAL_PURGE_T / $NB_PURGE_T))s"
	else echo -n "0"
	fi
	echo -ne " \t/ "
	if [ $NB_PURGE_T -gt 0 ]; then 
		echo -n $(echo "scale=2;$TOTAL_PURGE_LENGTH_T / 1000" | bc)" Meter"
	else echo -n "0"
	fi
	echo
done
echo -en "TX :\t"
if [ $NB_TX -gt 0 ]; then
        echo -n "$(($TOTAL_TX_TIME / $NB_TX))s"
	else echo -n "0"
fi
echo

echo "---------------------------------------------"
echo "               TOTAL FILAMENT                    "
echo "---------------------------------------------"
echo -e "Filament length  : \t "$(echo "scale=2;$FILAMENT_LENGTH / 1000" | bc)" Meter"
echo -e "Purge length     : \t "$(echo "scale=2;$TOTAL_PURGE_LENGTH / 1000" | bc)" Meter"

echo "---------------------------------------------"
echo "               TOTAL TIME                    "
echo "---------------------------------------------"
echo -e "Load          : \t $(date -d@$TOTAL_LOAD_TIME -u +%H:%M:%S)"
echo -e "Unload        : \t $(date -d@$TOTAL_UNLOAD_TIME -u +%H:%M:%S)"
echo -e "Pause         : \t $(date -d@$TOTAL_PAUSE_TIME -u +%H:%M:%S)"
echo -e "Purge         : \t $(date -d@$TOTAL_PURGE_TIME -u +%H:%M:%S)"
echo -e "Swap          : \t $(date -d@$TOTAL_TX_TIME -u +%H:%M:%S)"
echo -e "Print         : \t $(date -d@$(( $(tail -n1 /tmp/mmu_stat.log | cut -d":" -f1) - $(head -n1 /tmp/mmu_stat.log | cut -d":" -f1) )) -u +%H:%M:%S)"

echo "---------------------------------------------"
echo "                    ERROR                    "
echo "---------------------------------------------"
echo -e "\t | P \t | L \t | U \t | RL \t | RU \t | Cut \t | Runout|"
for i in $(seq 0 $NBEXT)
do
	echo -en "T$i \t | "
	echo -en "$(cat $FILE | grep ":T$i" | grep "ERROR:PAUSE" | wc -l) \t | "
	echo -en "$(cat $FILE | grep ":T$i" | grep "ERROR:LOAD" | wc -l) \t | "
	echo -en "$(cat $FILE | grep ":T$i" | grep "ERROR:ULOAD" | wc -l) \t | "
	echo -en "$(cat $FILE | grep ":T$i" | grep "ERROR:RLOAD" | wc -l) \t | "
	echo -en "$(cat $FILE | grep ":T$i" | grep "ERROR:RULOAD" | wc -l) \t | "
	echo -en "$(cat $FILE | grep ":T$i" | grep "ERROR:CUT" | wc -l) \t | "
	echo -en "$(cat $FILE | grep ":T$i" | grep "ERROR:RUNOUT" | wc -l) \t | "
	echo
done

echo "---------------------------------------------"
echo "              TOTAL ERROR                    "
echo "---------------------------------------------"
echo -e "Pause          :\t "$(cat $FILE | grep "ERROR:PAUSE" | wc -l)
echo -e "Load           :\t "$(cat $FILE | grep "ERROR:LOAD" | wc -l)
echo -e "Unload         :\t "$(cat $FILE | grep "ERROR:ULOAD" | wc -l)
echo -e "Retry Load     :\t "$(cat $FILE | grep "ERROR:RLOAD" | wc -l)
echo -e "Retry Unload   :\t "$(cat $FILE | grep "ERROR:RULOAD" | wc -l)
echo -e "Cut            :\t "$(cat $FILE | grep "ERROR:CUT" | wc -l)
echo -e "Runout            :\t "$(cat $FILE | grep "ERROR:RUNOUT" | wc -l)





