#!/usr/bin/env bash
  
#########################################################################
#########################################################################
###
####       Author: tutsmake
#####      Website: https://tutsmake.net
####
#########################################################################
#########################################################################
  
# Set the folder name formate with date (2022-05-28)
DATE_FORMAT=$(date +"%Y-%m-%d")
  
# MySQL server credentials
MYSQL_HOST="bd.ptrunners.net"
MYSQL_PORT="3306"
MYSQL_USER=""
MYSQL_PASSWORD=""

AWS_ENDPOINT_URL="http://s3.fr-par.scw.cloud"
  
# Path to local backup directory
LOCAL_BACKUP_DIR="/backup/dbbackup"
  
# Set s3 bucket name and directory path
S3_BUCKET_NAME="ptrunners"
S3_BUCKET_PATH="backups/db-backup"
  
# Number of days to store local backup files
BACKUP_RETAIN_DAYS=1 
  
# Use a single database or space separated database's names
DATABASES="ptrunner_ctbans ptrunner_customweapons ptrunner_discord ptrunner_donations ptrunner_gangs ptrunner_influx ptrunner_lrleaderboard ptrunner_lvlranks ptrunner_mostactives2 ptrunner_mostactive_new ptrunner_nodupeaccount ptrunner_playeranalytics ptrunner_shavit ptrunner_sourcebans ptrunner_sourcemod ptrunner_squads ptrunner_store ptrunner_weaponskins"
  
##### Do not change below this line
  
mkdir -p ${LOCAL_BACKUP_DIR}/${DATE_FORMAT}
  
LOCAL_DIR=${LOCAL_BACKUP_DIR}/${DATE_FORMAT}
REMOTE_DIR=s3://${S3_BUCKET_NAME}/${S3_BUCKET_PATH}
  
for db in $DATABASES; do
   mysqldump \
        -h ${MYSQL_HOST} \
        -P ${MYSQL_PORT} \
        -u ${MYSQL_USER} \
        -p${MYSQL_PASSWORD} \
        --single-transaction ${db} | gzip -9 > ${LOCAL_DIR}/${db}-${DATE_FORMAT}.sql.gz
  
        aws --endpoint-url ${AWS_ENDPOINT_URL} s3 cp ${LOCAL_DIR}/${db}-${DATE_FORMAT}.sql.gz ${REMOTE_DIR}/${DATE_FORMAT}/
done
  
DBDELDATE=`date +"${DATE_FORMAT}" --date="${BACKUP_RETAIN_DAYS} days ago"`
  
if [ ! -z ${LOCAL_BACKUP_DIR} ]; then
 cd ${LOCAL_BACKUP_DIR}
 if [ ! -z ${DBDELDATE} ] && [ -d ${DBDELDATE} ]; then
 rm -rf ${DBDELDATE}
  
 fi
fi
  
## Script ends here
