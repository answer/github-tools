#!/bin/bash

[ -f ~/.github-tools.rc ] && . ~/.github-tools.rc

if [ -z "$gitolite_ssh" ]; then
	echo "define gitolite_ssh var in ~/.github-tools.rc"
	exit
fi
if [ -z "$backup_dir" ]; then
	backup_dir=~/.backup-repos
fi

if [ ! -d "$backup_dir" ]; then
	mkdir -p "$backup_dir"
fi
if [ ! -d "$backup_dir" ]; then
	echo "failed create $backup_dir"
	exit
fi

for backup_setting in "${backup_repos[@]}"; do
	prefix=
	host=
	backup_repo=
	for setting in ${backup_setting[*]}; do
		if [ -z "$prefix" ]; then
			prefix=$setting
		elif [ -z "$host" ]; then
			host=$setting
		elif [ -z "$backup_repo" ]; then
			backup_repo=$setting
		fi
	done

	cd "$backup_dir"

	account=`dirname "$backup_repo"`
	mkdir -p "$account"
	cd "$account"

	repo=`basename "$backup_repo"`
	if [ ! -d "$repo" ]; then
		git clone "$host$backup_repo"
	fi

	cd "$repo"
	git push "$gitolite_ssh:$prefix/$backup_repo" refs/remotes/origin/*:refs/heads/*
done
