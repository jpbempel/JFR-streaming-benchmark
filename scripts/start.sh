#!/bin/bash
OPTIONS=""
if [ "$1" == "jfr" ];
then
  OPTIONS="-XX:StartFlightRecording=filename=petclinic.jfr,dumponexit=true,settings=profile"
fi
if [ "$1" == "jfr-streaming" ];
then
  OPTIONS="-DjfrStreaming=true"
fi
export JAVA_HOME=../../jdk/jdk
export PATH=$PATH:$JAVA_HOME/bin
$JAVA_HOME/bin/java ${OPTIONS} \
	-Xlog:gc:file=gc_$1.log \
    -DnbThreads=200 \
    -jar ../target/spring-petclinic-2.2.0.BUILD-SNAPSHOT.jar > out_petclinic.txt
