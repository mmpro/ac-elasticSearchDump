#!/bin/bash

####
# Call with ./batchBackup logstash 2017.01.01 2017.01.02

set -e

if [ -z "$1" ]
  then
    echo "Please provide an index prefix (e.g. logstash) date"
    exit
fi

if [ -z "$2" ]
  then
    echo "Please provide an start date (e.g. 2017.01.01)"
    exit
fi

if [ -z "$3" ]
  then
    echo "Please provide an end date (2017.12.31)"
    exit
fi

ESPREFIX=$1

# MAC VERSION
if [[ $4 == "MAC" ]]
then

  echo ">>>>>>>>>>> MAC VERSION <<<<<<<<<<<<<<<<"

  currentDateTs=$(date -j -f "%Y-%m-%d" $2 "+%s")
  endDateTs=$(date -j -f "%Y-%m-%d" $3 "+%s")
  offset=86400

  while [ "$currentDateTs" -le "$endDateTs" ]
  do
    date=$(date -j -f "%s" $currentDateTs "+%Y-%m-%d")
    echo $date

    # call the upload script - logstash-2017.01.05
    INDEX=$ESPREFIX-$(date -j -f "%s" $currentDateTs "+%Y.%m.%d")
    echo ""
    echo ">>>>>>>>> Starting backup for $INDEX"
     echo ""
   ./backup.sh $INDEX

    currentDateTs=$(($currentDateTs+$offset))

  done

else

  currentdate=$2
  loopenddate=$(/bin/date --date "$3 1 day" +%Y-%m-%d)

  until [ "$currentdate" == "$loopenddate" ]
  do
    echo $currentdate

    # call the upload script - logstash-2017.01.05
    INDEX=$ESPREFIX-$(date -d $currentdate "+%Y.%m.%d")
    echo ""
    echo ">>>>>>>>> Starting backup for $INDEX"
     echo ""
   ./backup.sh $INDEX

    currentdate=$(/bin/date --date "$currentdate 1 day" +%Y-%m-%d)
  done

fi
