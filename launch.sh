#!/bin/bash

set -x

cd /data

if ! [[ "$EULA" = "false" ]]; then
	echo "eula=true" > eula.txt
else
	echo "You must accept the EULA to install."
	exit 99
fi

if ! [[ -f 'ATM7-1.0.4-server.zip' ]]; then
	rm -fr defaultconfigs config kubejs libraries mods Simple.zip forge*.jar
	curl -Lo 'ATM7-1.0.4-server.zip' 'https://edge.forgecdn.net/files/5199/628/ATM7-1.0.4-server.zip' && unzip -u -o 'ATM7-1.0.4-server.zip' -d /data
	if [[ -d $(echo ATM7-1.0.4-server.zip | sed 's/.zip//') ]]; then
		mv -f $(echo ATM7-1.0.4-server.zip | sed 's/.zip//')/* /data
		rm -fr $(echo ATM7-1.0.4-server.zip | sed 's/.zip//')
	fi
	java -jar $(ls forge-*-installer.jar) --installServer
fi

if [[ -n "$JVM_OPTS" ]]; then
	sed -i '/-Xm[s,x]/d' user_jvm_args.txt
	for j in ${JVM_OPTS}; do sed -i '$a\'$j'' user_jvm_args.txt; done
fi
if [[ -n "$MOTD" ]]; then
    sed -i "s/motd\s*=/ c motd=$MOTD" /data/server.properties
fi
if [[ -n "$OPS" ]]; then
    echo $OPS | awk -v RS=, '{print}' > ops.txt
fi
if [[ -n "$ALLOWLIST" ]]; then
    echo $ALLOWLIST | awk -v RS=, '{print}' > white-list.txt
fi

sed -i 's/server-port.*/server-port=25565/g' server.properties
chmod 755 startserver.sh

./startserver.sh