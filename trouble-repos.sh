#!/bin/bash

repos=(
    "ssh://git@stash.atlassian.roh.org.uk/web/fastly---configuration.git"
    "ssh://git@stash.atlassian.roh.org.uk/web/information-symfony.git"
    "ssh://git@stash.atlassian.roh.org.uk/web/wordpress.git"
    "ssh://git@stash.atlassian.roh.org.uk/web2/account-service.git"
    "ssh://git@stash.atlassian.roh.org.uk/web2/api-doc.git"
    "ssh://git@stash.atlassian.roh.org.uk/web2/checkout-service.git"
    "ssh://git@stash.atlassian.roh.org.uk/web2/frontend.git"
    "ssh://git@stash.atlassian.roh.org.uk/web2/information-api.git"
    "ssh://git@stash.atlassian.roh.org.uk/web2/information-lambda.git"
    "ssh://git@stash.atlassian.roh.org.uk/web2/membership-direct-debit.git"
    "ssh://git@stash.atlassian.roh.org.uk/web2/prismic-schema.git"
    "ssh://git@stash.atlassian.roh.org.uk/web2/redesign-stack.git"
    "ssh://git@stash.atlassian.roh.org.uk/web2/roh-frontend.git"
    "ssh://git@stash.atlassian.roh.org.uk/cin/cinema-is-website.git"
)

newRepos=(
    "ssh://git@bitbucket.atlassian.roh.org.uk:7999/web/fastly-configuration.git"
    "ssh://git@bitbucket.atlassian.roh.org.uk:7999/lw/information-symfony.git"
    "ssh://git@bitbucket.atlassian.roh.org.uk:7999/lw/wordpress.git"
    "ssh://git@bitbucket.atlassian.roh.org.uk:7999/web/account-service.git"
    "ssh://git@bitbucket.atlassian.roh.org.uk:7999/web/api-doc.git"
    "ssh://git@bitbucket.atlassian.roh.org.uk:7999/web/checkout-service.git"
    "ssh://git@bitbucket.atlassian.roh.org.uk:7999/web/frontend.git"
    "ssh://git@bitbucket.atlassian.roh.org.uk:7999/web/information-api.git"
    "ssh://git@bitbucket.atlassian.roh.org.uk:7999/web/information-lambda.git"
    "ssh://git@bitbucket.atlassian.roh.org.uk:7999/web/membership-direct-debit.git"
    "ssh://git@bitbucket.atlassian.roh.org.uk:7999/web/prismic-schema.git"
    "ssh://git@bitbucket.atlassian.roh.org.uk:7999/web/redesign-stack.git"
    "ssh://git@bitbucket.atlassian.roh.org.uk:7999/web/roh-frontend.git"
    "ssh://git@bitbucket.atlassian.roh.org.uk:7999/aw/cinema-is-website.git"
)

timestamp() {
	date +"%F %T:%N" # current time
}
logMessage() {
	echo "\"$1\" [$(timestamp)] \"$2\"" >> $logPath/log
}

logPath=$(pwd)
absolutePath="$(cd ../"$(dirname "$1")"; pwd -P)/$(basename "$1")"
repositoriesDir="${absolutePath}trouble-repos"

# git branch -r | grep -v '\->' | while read remote; do echo "$remote + $remote"; done

# exit

logMessage "Start" "Begin Trouble Repo Sync."
$counter
for i in "${repos[@]}"
do
    echo "$i"
    echo 
    
    newArr=(${i//\// })
    dirName=${newArr[3]/\.git/ }
    echo "$dirName"

    if [ ! -d  $repositoriesDir/$dirName ]; then
		logMessage ${dirName} "Build Dir ${dirName}."
		mkdir $repositoriesDir/$dirName
	fi

    cd $repositoriesDir/$dirName

	if [ ! -d ".git" ]; then
		logMessage ${dirName} "Clone ${i}."
		cloneResponse=$(git clone $i . 2>&1)
		logMessage ${dirName} ${cloneResponse}
		logMessage ${dirName} "Clone complete."
	fi

    # track all remote branches
    git branch -r | grep -v '\->' | while read remote; do git branch --track "${remote#origin/}" "$remote"; done

    if [ ! -d  $repositoriesDir/$dirName ]; then
        rm -Rf $repositoriesDir/$dirName/.git/hooks
    fi

    logMessage ${dirName} "Add remote ${newRepos[$counter]}."
    git remote add bitbucket ${newRepos[$counter]}

    logMessage ${dirName} "Push all to bitbucket."
	pushResponse=$(git push --all bitbucket 2>&1)
	logMessage  ${dirName} "Push Response: ${pushResponse}."

	cd $repositoriesDir
    ((counter = counter +1))
    
done

echo $counter