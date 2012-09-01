#!/bin/sh
cd `dirname $0`

# Check arguments
if [ $# != 1 ] ; then 
	if [ ! -e FakID.host ]; then
		echo "USAGE: $0 [Host]"
		exit 1
	fi
	HOST=`cat FakID.host`
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
ssh root@$HOST "rm /Library/MobileSubstrate/DynamicLibraries/FakPREF.*">&- 2>&- 
ssh root@$HOST "mkdir /System/Library/Audio/UISounds/New">&- 2>&- 
ssh root@$HOST "rm /System/Library/Audio/UISounds/New/spel1">/dev/null
scp ../FakPREF/spel1 root@$HOST:/System/Library/Audio/UISounds/New/spel1
scp ../FakPREF/FakPREF.plist root@$HOST:/Library/MobileSubstrate/DynamicLibraries/FakPREF.plist
scp ../FakPREF/FakPREF.dylib root@$HOST:/Library/MobileSubstrate/DynamicLibraries/FakPREF.dylib

# Copy SpringBoard
ssh root@$HOST "rm /System/Library/CoreServices/SpringBoard.app/SpringBoard">/dev/null
scp ../SpringBoard/SpringBoard root@$HOST:/System/Library/CoreServices/SpringBoard.app/SpringBoard
ssh root@$HOST "chmod 755 /System/Library/CoreServices/SpringBoard.app/SpringBoard"

# Copy lockdownd
ssh root@$HOST "killall lockdownd">/dev/null
ssh root@$HOST "killall lockdownd">/dev/null
ssh root@$HOST "rm /usr/libexec/lockdownd">/dev/null
scp ../lockdownd/lockdownd root@$HOST:/usr/libexec/lockdownd
ssh root@$HOST "chmod 755 /usr/libexec/lockdownd"

# Check result
scp GetID root@$HOST:/usr/bin/GetID
ssh root@$HOST "chmod 755 /usr/bin/GetID"
ssh root@$HOST "/usr/bin/GetID"
ssh root@$HOST "rm /usr/bin/GetID"

# Kill SpringBoard
ssh root@$HOST "killall SpringBoard"
