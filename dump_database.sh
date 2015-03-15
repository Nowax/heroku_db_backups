#!/bin/bash

# Script for Heroku's database backups functionality automation
# witten by Wojciech Nowak (https://github.com/nowax)
#
# Script creates new backup and downloads it to local directory
#
# See more https://devcenter.heroku.com/articles/heroku-postgres-backups

if [ -n "$1" ]
then
	app_name=$1

	heroku pg:backups --app $app_name

	string_containing_backup_name=`heroku pg:backups capture --app $app_name`
	backup_name=`[[ $string_containing_backup_name =~ (b[0-9]{3}) ]] && echo ${BASH_REMATCH[1]}`
	printf "\n\nStart download preparation for backup: $backup_name\n"

	string_containing_backup_url=`heroku pg:backups public-url $backup_name --app $app_name`
	backup_url=`[[ $string_containing_backup_url =~ \'(.*)\' ]] && echo ${BASH_REMATCH[1]}`

	printf "\n\nDownloading latest database dump...\n"
	file_name="${app_name}_${backup_name}_`date -u '+%Y-%m-%dT%H:%M:%S%z'`.dump"
	directory="dumps"
	if [ ! -d "$directory" ]; then
		mkdir $directory
	fi
	wget -O $directory/$file_name $backup_url
else
	printf "Aplication name not provided! Please try again with typing app name as a argument...\n"
fi

