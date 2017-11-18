#!/bin/bash    
. `dirname $0`/passwd
FTPURL="ftp://$USER:$PASS@$HOST"
LCD=$(git rev-parse --show-toplevel)
RCD="/"
cd $LCD
DELETE="--delete"
lftp -c "set ftp:list-options -a;
open '$FTPURL';
lcd $LCD;
cd $RCD;
mirror --reverse \
       $DELETE \
       --verbose \
       --exclude=\.git \
       --exclude=.*node_modules \
       --exclude=.DS_Store \
       --exclude=.git"
