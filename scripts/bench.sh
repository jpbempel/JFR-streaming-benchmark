#!/bin/bash
INJECT_COUNT=1
OUTPUT_FILE=out_petclinic.txt
THREADS=2

function bench () {
  if [ "$1" == "" ];
  then
    echo "Missing tag"
    exit 1
  fi
  TAG=$1
  for I in $(seq $INJECT_COUNT);
  do
    if [ -f $OUTPUT_FILE ];
    then
      rm $OUTPUT_FILE
    fi
    echo "$(date +%H:%M:%S) Starting application ${TAG} run $I/$INJECT_COUNT..."
    ./start.sh $TAG &
    PID=$!
    DEAD=0
    sleep 0.2
    while [ "$(grep -o "Started PetClinicApplication" $OUTPUT_FILE)" != "Started PetClinicApplication" -a "$DEAD" != "1" ];
    do
      kill -0 $PID
      DEAD=$?
      sleep 1
    done
    if [ "$DEAD" == "1" ];
    then
      echo "Application not started correctly!"
      exit 1
    fi
    pidstat -r -C java 1 > mem-${TAG}-${I}.txt &
    echo "$(date +%H:%M:%S) Sending requests..."
    pids=()
    for FORK in $(seq $THREADS);
    do
      ./inject.sh results_${TAG}-${I}_${FORK}.csv &
      pids[$FORK]=$!
    done
    for FORK in $(seq $THREADS);
    do
      pid=${pids[$FORK]}
      wait $pid
    done
    # grab user  cpu ticks
    java_pid=$(pgrep java)
    echo "java pid: $java_pid"
    cat /proc/$java_pid/stat | cut -d " " -f 14 > cpu_ticks_${TAG}-${I}.txt
    cat /proc/$java_pid/status | grep ctxt_switches > ctxt_switches_${TAG}-${I}.txt
    for FORK in $(seq $THREADS);
    do
      cat results_${TAG}-${I}_${FORK}.csv >> results_${TAG}-${I}.csv
    done
    echo "Killing $PID"
    pkill -P $PID
    pkill pidstat
    # report RSS
    cat mem-${TAG}-${I}.txt | grep java | cut --bytes=57-63 > rss-${TAG}-${I}.csv
    sleep 1
  done
  python percentiles.py ${TAG}.csv results_${TAG}-?.csv
}

bench none
bench jfr
bench jfr-streaming


