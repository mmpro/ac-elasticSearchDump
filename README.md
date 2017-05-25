# AC Elastic Search Dump

A little Bash script to flush, export, upload to S3 and close or delete indices.

Create a credentials.txt file with your credentials and data. The backup.sh script contains a blueprint in its header.

Create a tmp folder where the export data will be stored.

Make sure to chmod a+x the backup.sh file and the just call ./backup.sh and watch.

# Installation
You will need npm and curl and aws-cli. 

Then install elasticdump using npm -i elasticdump -g


