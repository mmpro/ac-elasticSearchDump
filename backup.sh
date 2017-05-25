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

source credentials.txt

EXPORTFILEMAPPING=./tmp/$INDEX'-mapping.json'
EXPORTFILE=./tmp/$INDEX'.json'

# remove files if existing
rm $EXPORTFILEMAPPING
rm $EXPORTFILE

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
aws s3 cp $EXPORTFILEMAPPING s3://$UPLOADLOC/$EXPORTFILEMAPPING
echo ""
echo "Uploaded mapping "$EXPORTFILEMAPPING
echo "#######################"
echo ""

aws s3 cp $EXPORTFILE s3://$UPLOADLOC/$EXPORTFILE
echo ""
echo "Uploaded mapping "$EXPORTFILE
echo "#######################"
echo ""
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

# clean up and remove local files
rm $EXPORTFILEMAPPING
rm $EXPORTFILE


echo "BACKUP COMPLETE"
