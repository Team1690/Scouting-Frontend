#!/usr/bin/bash
Commit=`git log -1 --pretty=%B | head -1`

if [[ ! -d ./build/web ]]
then
	mkdir -p ./build/web
    
fi

cd build/web/

if [[ -d ./.git ]]
then
	git pull origin main
else
	git clone git@github.com:Team1690/Team1690.github.io.git .
fi


flutter build web --web-renderer html --release 
git add .
git commit -m "$Commit"
git push origin main
cd ../..
