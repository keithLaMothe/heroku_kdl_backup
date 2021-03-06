#!/bin/bash

PYTHONHOME=/app/vendor/awscli/
FILENAME=`date +%Y_%m_%d_%H_%M`

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

MYSQL_PWD=$DB_BACKUP_PASSWORD mysqldump --no-tablespaces --set-gtid-purged=OFF -h $DB_BACKUP_HOST -u$DB_BACKUP_USER $DB_BACKUP_DATABASE | gzip > /tmp/"${FILENAME}".sql.gz
AWS_ACCESS_KEY_ID=$DB_BACKUP_AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$DB_BACKUP_AWS_SECRET_ACCESS_KEY /app/vendor/bin/aws --region $DB_BACKUP_AWS_DEFAULT_REGION s3 cp /tmp/"${FILENAME}".sql.gz s3://"$DB_BACKUP_S3_BUCKET_PATH/${FILENAME}".sql.gz
rm -rf /tmp/"${FILENAME}".sql.gz
