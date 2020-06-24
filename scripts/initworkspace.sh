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
  curl -OL https://builds.shipilev.net/openjdk-jdk15/openjdk-jdk15-latest-linux-x86_64-release.tar.xz
  tar xJvf openjdk-jdk15-latest-linux-x86_64-release.tar.xz
  popd
fi
echo "Building spring-petclinic"
cd $BASEDIR/JFR-streaming-benchmark
export JAVA_HOME=$BASEDIR/jdk/jdk
./mvnw spring-javaformat:apply package -DskipTests=true
