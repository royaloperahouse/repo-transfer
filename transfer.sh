#!/bin/bash

timestamp() {
	date +"%T:%N" # current time
}

logPath=$(pwd)
logMessage() {
	echo "\"$1\" [$(timestamp)] \"$2\"" >> $logPath/log
}

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
		git clone $OLD .
		logMessage ${dirName} "Clone complete."
	fi

	if git ls-remote bitbucket > /dev/null; then
		logMessage ${dirName} "Bitbucket remote exists. Fetch latest from origin and merge"
		git fetch origin
		mergeResponse=$(git merge origin/master 2>&1)
		logMessage ${dirName} "Merge Response: ${mergeResponse}"
	else
		logMessage ${dirName} "Bitbucket doesn't exist. Add remote ${NEW}."
		git remote add bitbucket $NEW
	fi

	logMessage ${dirName} "Push Master to bitbucket."
	pushResponse=$(git push bitbucket master 2>&1)
	logMessage  ${dirName} "Push Response: ${pushResponse}."
	cd $repositoriesDir
	
done < repository-cleanup.csv

logMessage "End" "End Repo Sync"

exit

