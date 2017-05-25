#!/usr/bin/env bash
#######
# Create file name retireCredentials.cfg where all relevant vars are defined:
#AUTH=username:password
#ESURL=host:port

#INDEX=Indexname
#UPLOADLOC=bucket/folder

# 1 = true, 0 = false
#UPLOADINDEX=1
#CLOSEINDEX=0
#DELETEINDEX=1
############

# exit on error
set -e
source credentials.txt

INDEX=${1:-$INDEX}


EXPORTFILEMAPPING=./tmp/$INDEX'-mapping.json'
EXPORTFILE=./tmp/$INDEX'.json'


# flush index
curl -X POST https://$ESURL/$INDEX/_flush -u $AUTH
echo ""
echo "Flushed "$INDEX
echo "#######################"
echo ""

# export mapping
elasticdump --input=https://$AUTH@$ESURL/$INDEX --output=$EXPORTFILEMAPPING --type='mapping'
echo ""
echo "Mapping exported "$EXPORTFILEMAPPING
echo "#######################"
echo ""

# export mapping
elasticdump --input=https://$AUTH@$ESURL/$INDEX --output=$EXPORTFILE --type='data' --limit=1000
echo ""
echo "Data exported "$EXPORTFILE
echo "#######################"
echo ""

if [[ $UPLOADINDEX -eq 1 ]]; then
find ./tmp -type f | while read line

do
if [ -e "$line" ]; then
FILENAME="${line##*/}"
echo "Uploading $line to S3 $FILENAME"
aws s3 cp $line s3://$UPLOADLOC/$FILENAME
if [[ $? -eq 0 ]]; then
rm $line
echo "Upload complete and local file delete: $line"
fi
fi
done

fi

# close index
if [[ $CLOSEINDEX -eq 1 ]]; then
curl -X POST https://$ESURL/$INDEX/_close -u $AUTH
echo ""
echo "Closed "$INDEX
echo "#######################"
echo ""
fi

# delete index
if [[ $DELETEINDEX -eq 1 ]]; then
curl -X DELETE https://$ESURL/$INDEX -u $AUTH
echo ""
echo "Deleted "$INDEX
echo "#######################"
echo ""
fi


echo "BACKUP COMPLETE"
