#!/bin/bash

timestamp() {
	date +"%F %T:%N" # current time
}
logMessage() {
	echo "\"$1\" [$(timestamp)] \"$2\"" >> $logPath/log
}

logPath=$(pwd)
# https://stackoverflow.com/questions/3915040/how-to-obtain-the-absolute-path-of-a-file-via-shell-bash-zsh-sh
absolutePath="$(cd ../"$(dirname "$1")"; pwd -P)/$(basename "$1")"
repositoriesDir="${absolutePath}repositories"

logMessage "Start" "Begin Repo Sync."

while IFS=, read -r OLD NEW
do
	newArr=(${NEW//\// })
	dirName=${newArr[3]/\.git/ }
	
	if [ ! -d  $repositoriesDir/$dirName ]; then
		logMessage ${dirName} "Build Dir ${dirName}."
		mkdir $repositoriesDir/$dirName
	fi

	cd $repositoriesDir/$dirName

	if [ ! -d ".git" ]; then
		logMessage ${dirName} "Clone ${OLD}."
		cloneResponse=$(git clone --mirror $OLD . 2>&1)
		logMessage ${dirName} ${cloneResponse}
		logMessage ${dirName} "Clone complete."
	fi

	if git config remote.bitbucket.url; then
		logMessage ${dirName} "Bitbucket remote exists. Fetch latest from origin and merge"
		git pull
		mergeResponse=$(git merge origin/master 2>&1)
		logMessage ${dirName} "Merge Response: ${mergeResponse}"
	else
		logMessage ${dirName} "Bitbucket doesn't exist. Add remote ${NEW}."
		git remote add bitbucket $NEW
	fi

	logMessage ${dirName} "Push all to bitbucket."
	pushResponse=$(git push --mirror bitbucket 2>&1)
	logMessage  ${dirName} "Push Response: ${pushResponse}."
	cd $repositoriesDir
	
done < repository-cleanup.csv

logMessage "End" "End Repo Sync"

exit
