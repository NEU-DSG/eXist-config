#! /bin/bash

# Move any files that are > 90 days old from the eXist backup
# directory to a storage depot.

# Written 2016-02-03/04 by Syd Bauman
# Copyleft 2016 Syd Bauman

# --------- subroutines ---------
die()
{
    echo
    echo "$myroot ERROR: $@"
    echo "This was a fatal error at $(date '+%Y-%m-%d %H:%M:%S.%N')"
    cd ${sWD}
    exit 1
}
warn()
{
    echo
    echo "$myroot WARNING at $(date '+%Y-%m-%d %H:%M:%S.%N'):"
    echo "$@"
}
# --------- end subroutines ---------

#
# get my own name and path
#
mypath=${0%/*}
myname=${0##*/}
myname=${myname#./}
myroot=${myname%.*}

# Watch what happens, as it happens
#set -o xtrace

# save current working directory so we can get back here
sWD=`pwd`

# default is to move files > 90 days old
DAYS=${DAYS:-89}

#
# source and target directories depend on where I am
#
HOST=${HOST:-$(hostname --all-fqdns | egrep 'wwp|tap' | perl -pe 's,\..*$,,;')}
if [ .$HOST = . ]; then die "Unable to ascertain hostname of where I am."; fi
if [ $HOST = wwp ]  ||  [ $HOST = wwp-test ]; then
    SRC=${SRC:-/opt/local/eXist-2.2/webapp/WEB-INF/data/backup/consistency/}
    USR=wwp
    REM=${REM:-${USR}@data.dsg.neu.edu}
    TAR=${TAR:-Documents/WWP_backups/eXist/${HOST}/}
elif [ $HOST = tapas ]  ||  [ $HOST = tapasdev ]; then
    SRC=${SRC:-/opt/local/eXist-data/backup/consistency/}
    USR=tapas
    REM=${REM:-${USR}@data.dsg.neu.edu}
    TAR=${TAR:-Documents/eXist_backups/${HOST}/}
else
    die "What? I don't know where the eXist source is on $HOST, let alone where it goes."
fi

# change to source directory
cd ${SRC} || die "Unable to get to source dir ${SRC}."

# create target directory, if not already there
sudo -u exist ssh ${REM} mkdir -p ${TAR} || warn "Unable to create remote dir ${TAR} (on ${REM})."

# get the list of files to transfer; all those > DAYS old
tLIST=${tLIST:-$(find . -mtime +${DAYS})}

sudo -u exist scp -p ${tLIST} ${REM}:${TAR} || die "could not scp ${tLIST} to ${REM}:${TAR}."
sudo -u exist rm ${tLIST} || die "could not delete transfered files: ${tLIST}."

cd $sWD || die "Unable to get back to where I started from."
