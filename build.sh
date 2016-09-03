#!/bin/bash

RAINBOW_VERSION=51

echo "cleaning old stuff"

rm -r src/*
rm -r src

echo decompiling rainbow v.$RAINBOW_VERSION

if [ -e decompiled/Rainbow-$RAINBOW_VERSION.jar ]
then
  echo "already decompiled... skipping"
else
  java -jar fernflower.jar -dgs=1 -hdc=0 -rbr=0 -asc=1 Rainbow-$RAINBOW_VERSION.jar -e=libs/commons-codec-1.9.jar -e=libs/commons-io-2.4.jar -e=libs/commons-lang3-3.3.2.jar -e=libs/gson-2.2.4.jar -e=libs/guava-15.0.jar -e=libs/log4j-api-2.0-beta9.jar -e=libs/log4j-core-2.0-beta9.jar -e=libs/netty-all-4.0.18.Final.jar -e=libs/rt.jar -e=libs/authlib-1.5.17.jar -e=libs/trove4j-3.0.3.jar -e=libs/colt-1.2.0.jar decompiled/ || exit 1
fi

echo 'extracting files'

mkdir src/
unzip decompiled/Rainbow-$RAINBOW_VERSION.jar -d src/ || exit 1
./jacobe -nobackup -overwrite -outext=java src

echo 'applying patches'

rm src/joebkt/axt_EmptyEnum.java
rm src/joebkt/axu_EmptyEnum.java
rm src/joebkt/axv_EmptyEnum.java
rm src/joebkt/axw_EmptyEnum.java
rm src/joebkt/axx_EmptyEnum.java
rm src/joebkt/axy_EmptyEnum.java
rm src/joebkt/ha.java
rm src/joebkt/hb.java
rm src/joebkt/hc.java
git apply fix.patch || exit 1
git apply patches/*.patch || exit 1
git apply morepatches/*.patch || exit 1
#for file in "patches/"*".patch"
#do
#  echo "applying $file"
#  git apply "$file"
#done

echo "recompiling rainbow"

mkdir classes
javac -source 1.6 -target 1.6 -sourcepath src -classpath "libs/*" $(find ./src/* | grep \\.java) -d classes || exit 1
cp -r src/* classes || exit 1
rm $(find ./classes/* | grep \\.java)
unzip -n libs/colt-1.2.0.jar -d classes/
unzip -n libs/commons-codec-1.9.jar -d classes/
unzip -n libs/commons-io-2.4.jar -d classes/
unzip -n libs/commons-lang3-3.3.2.jar -d classes/
unzip -n libs/authlib-1.5.17.jar -d classes/
unzip -n libs/gson-2.2.4.jar -d classes/
unzip -n libs/guava-15.0.jar -d classes/
unzip -n libs/log4j-api-2.0-beta9.jar -d classes/
unzip -n libs/log4j-core-2.0-beta9.jar -d classes/
unzip -n libs/netty-all-4.0.18.Final.jar -d classes/
unzip -n libs/trove4j-3.0.3.jar -d classes/
jar cvmf src/META-INF/MANIFEST.MF Rainbow-v$RAINBOW_VERSION-patched.jar -C classes . || exit 1
rm -r classes/
echo "successfully patched rainbow"
