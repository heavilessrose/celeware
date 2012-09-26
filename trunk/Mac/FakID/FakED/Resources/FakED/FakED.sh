#!/bin/sh
cd `dirname $0`

# Check arguments
clear
if [ $# != 1 ] ; then
#echo "USAGE: $0 [Host]"
	echo "ENTER iPhone's host name or IP address:"
	read HOST
else
	HOST=$1
fi

# Prepare ssh keys
echo Preparing for deployment...
if [ ! -e ~/.ssh/id_rsa ]; then
	ssh-keygen -t rsa
fi
ssh root@$HOST "mkdir ~/.ssh">&- 2>&-
if [ $? == 255 ]; then
	echo Could not connect to $HOST.
	exit 255
fi
scp ~/.ssh/id_rsa.pub root@$HOST:~/.ssh/authorized_keys>/dev/null

# Copy FakePREF
#ssh root@$HOST "rm /Library/MobileSubstrate/DynamicLibraries/FakID.*">&- 2>&- 
#ssh root@$HOST "mkdir /System/Library/Audio/UISounds/New">&- 2>&- 
#ssh root@$HOST "rm /System/Library/Audio/UISounds/New/spel1">&- 2>&-
#scp ../FakID/spel1 root@$HOST:/System/Library/Audio/UISounds/New/spel1
#scp ../FakID/FakID.plist root@$HOST:/Library/MobileSubstrate/DynamicLibraries/FakID.plist
#scp ../FakID/FakID.dylib root@$HOST:/Library/MobileSubstrate/DynamicLibraries/FakID.dylib

# Copy lockdownd
ssh root@$HOST "killall lockdownd">/dev/null
ssh root@$HOST "killall lockdownd">/dev/null
ssh root@$HOST "rm /usr/libexec/lockdownd">/dev/null
scp ../lockdownd/lockdownd root@$HOST:/usr/libexec/lockdownd
ssh root@$HOST "chmod 755 /usr/libexec/lockdownd"

# Copy Preferences
ssh root@$HOST "killall Preferences"
ssh root@$HOST "rm /Applications/Preferences.app/Preferences">/dev/null
scp ../Preferences/Preferences root@$HOST:/Applications/Preferences.app/Preferences
ssh root@$HOST "chmod 755 /Applications/Preferences.app/Preferences"

# Copy SpringBoard
ssh root@$HOST "rm /System/Library/CoreServices/SpringBoard.app/SpringBoard">/dev/null
scp ../SpringBoard/SpringBoard root@$HOST:/System/Library/CoreServices/SpringBoard.app/SpringBoard
ssh root@$HOST "chmod 755 /System/Library/CoreServices/SpringBoard.app/SpringBoard"
ssh root@$HOST "killall SpringBoard"

# Check result
scp FakLOG root@$HOST:/usr/bin/FakLOG
ssh root@$HOST "chmod 755 /usr/bin/FakLOG"
ssh root@$HOST "/usr/bin/FakLOG"
ssh root@$HOST "rm /usr/bin/FakLOG"
