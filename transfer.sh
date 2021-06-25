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
	
	logMessage ${dirName} "Build Dir ${dirName}."
	mkdir $dirName

	cd $dirName
	logMessage ${dirName} "Clone ${OLD}."
	cloneResponse=$(git clone $OLD . 2>&1)

	logMessage ${dirName} "Clone Response: ${cloneResponse}."

	logMessage ${dirName} "Add remote ${NEW}."
	git remote add bitbucket $NEW

	#logMessage "$(git remote -v)"

	logMessage ${dirName} "Push Master to bitbucket."
	pushResponse=$(git push bitbucket master)
	logMessage  ${dirName} "Push Response: ${pushResponse}."
	cd ..

	logMessage ${dirName} "Delete Dir ${dirName}."
	rm -Rf $dirName
done < repository-cleanup.csv

logMessage "End" "End Repo Sync"

exit

