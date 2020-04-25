#!/bin/bash
if [ "$1" == "" ];
then
  BASEDIR=$(cd ../..; pwd)
else
  BASEDIR=$1
fi
echo "Base directory: $BASEDIR"
if [ ! -d $BASEDIR/jdk/jdk-14.0.1+7 ];
then
  echo "Downloading JDKs..."
  pushd .
  cd $BASEDIR
  mkdir jdk
  cd jdk
  curl -OL https://github.com/AdoptOpenJDK/openjdk14-binaries/releases/download/jdk-14.0.1%2B7/OpenJDK14U-jdk_x64_linux_hotspot_14.0.1_7.tar.gz
  tar xzvf OpenJDK14U-jdk_x64_linux_hotspot_14.0.1_7.tar.gz
  popd
fi
echo "Building spring-petclinic"
cd $BASEDIR/JFR-streaming-benchmark
export JAVA_HOME=$BASEDIR/jdk/jdk-14.0.1+7
./mvnw package -DskipTests=true
