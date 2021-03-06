#!/bin/bash

timestamp() {
	date +"%F %T:%N" # current time
}
logMessage() {
	echo "\"$1\" [$(timestamp)] \"$2\"" >> $logPath/log
}

logPath=$(pwd)
absolutePath="$(cd ../"$(dirname "$1")"; pwd -P)/$(basename "$1")"
repositoriesDir="${absolutePath}trouble-repos"

logMessage "Start" "Begin Trouble Repo Sync."

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
		cloneResponse=$(git clone $OLD . 2>&1)
		logMessage ${dirName} ${cloneResponse}
		logMessage ${dirName} "Clone complete."
	fi

    # track all remote branches
    git branch -r | grep -v '\->' | while read remote; do git branch --track "${remote#origin/}" "$remote"; done

    if [ ! -d  $repositoriesDir/$dirName ]; then
        rm -Rf $repositoriesDir/$dirName/.git/hooks
    fi

    logMessage ${dirName} "Add remote $NEW."
    git remote add bitbucket $NEW

    logMessage ${dirName} "Push all to bitbucket."
	pushResponse=$(git push --all bitbucket 2>&1)
	logMessage  ${dirName} "Push Response: ${pushResponse}."

	cd $repositoriesDir
	
done < trouble-repositories.csv

exit