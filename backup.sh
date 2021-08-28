#!/bin/bash

PYTHONHOME=/app/vendor/awscli/
Green='\033[0;32m'
EC='\033[0m'
FILENAME=`date +%Y%m%d_%H_%M`

# terminate script on any fails
set -e

if [[ -z "$DB_BACKUP_AWS_ACCESS_KEY_ID" ]]; then
  echo "Missing DB_BACKUP_AWS_ACCESS_KEY_ID variable"
  exit 1
fi
if [[ -z "$DB_BACKUP_AWS_SECRET_ACCESS_KEY" ]]; then
  echo "Missing DB_BACKUP_AWS_SECRET_ACCESS_KEY variable"
  exit 1
fi
if [[ -z "$DB_BACKUP_AWS_DEFAULT_REGION" ]]; then
  echo "Missing DB_BACKUP_AWS_DEFAULT_REGION variable"
  exit 1
fi
if [[ -z "$DB_BACKUP_S3_BUCKET_PATH" ]]; then
  echo "Missing DB_BACKUP_S3_BUCKET_PATH variable"
  exit 1
fi
if [[ -z "$DB_BACKUP_HOST" ]] ; then
  echo "Missing DB_BACKUP_HOST variable"
  exit 1
fi
if [[ -z "$DB_BACKUP_USER" ]] ; then
  echo "Missing DB_BACKUP_USER variable"
  exit 1
fi
if [[ -z "$DB_BACKUP_PASSWORD" ]] ; then
  echo "Missing DB_BACKUP_PASSWORD variable"
  exit 1
fi
if [[ -z "$DB_BACKUP_DATABASE" ]] ; then
  echo "Missing DB_BACKUP_DATABASE variable"
  exit 1
fi

printf "${Green}Start dump${EC}"
mysqldump --no-tablespaces --set-gtid-purged=OFF -h $DB_BACKUP_HOST -p$DB_BACKUP_PASSWORD -u$DB_BACKUP_USER $DB_BACKUP_DATABASE | gzip > /tmp/"${FILENAME}".gz

printf "${Green}Move dump to AWS${EC}"
AWS_ACCESS_KEY_ID=$DB_BACKUP_AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$DB_BACKUP_AWS_SECRET_ACCESS_KEY /app/vendor/bin/aws --region $DB_BACKUP_AWS_DEFAULT_REGION s3 cp /tmp/"${FILENAME}".gz s3://$DB_BACKUP_S3_BUCKET_PATH/${FILENAME}".gz

# cleanup
rm -rf /tmp/"${FILENAME}".gz
