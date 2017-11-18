#!/bin/bash    
. `dirname $0`/passwd
FTPURL="ftp://$USER:$PASS@$HOST"
LCD=$(git rev-parse --show-toplevel)
RCD="/"
#DELETE="--delete"
lftp -c "set ftp:list-options -a;
open '$FTPURL';
lcd $LCD;
cd $RCD;
mirror \
       $DELETE \
       --verbose \
       --exclude-glob .git \
       --exclude-glob push.sh \
       --exclude-glob pull.sh "
