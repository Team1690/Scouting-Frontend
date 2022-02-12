#!/usr/bin/bash
Commit=`git log -1 --pretty=%B | head -1`

if [[ ! -d ./build/web ]]
then
	mkdir -p ./build/web
    
fi

cd build/web/

if [[ -d ./.git ]]
then
	git pull origin master
else
	git clone git@github.com:itamarsch/itamarsch.github.io.git .
fi


flutter build web --web-renderer html --release 
git add . 
git commit -m "$Commit"
git push origin master
cd ../..