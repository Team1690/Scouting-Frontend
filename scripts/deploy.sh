#!/usr/bin/env sh
set -Eeuxo pipefail

commit=$(git log -1 --pretty=%B | head -1)

if [[ ! -d ./build/web ]]
then
	mkdir -p ./build/web
fi

pushd build/web/
	if [[ -d ./.git ]]
	then
		git pull origin main
	else
		git clone --filter=tree:0 git@github.com:Team1690/Team1690.github.io.git .
	fi
	./build.sh --release
	git add . 
	git commit -m "${commit}"
	git push origin main
popd
