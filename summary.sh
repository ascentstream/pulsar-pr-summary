#!/usr/bin/env bash

LIMIT=${LIMIT:-100}
BRANCH=${BRANCH:-master}
START_DATE=${START_DATE:-$(date +%Y-%m-%d)}
END_DATE=${END_DATE:-$(date +%Y-%m-%d)}

function fetch() {
    echo -e "# $START_DATE..$END_DATE - $BRANCH\n| 标题 | 链接 | 作者 | 标签 |\n| - | :--: | :--: | - |" && gh pr list -R apache/pulsar --search "merged:$START_DATE..$END_DATE base:$BRANCH" --limit 100  --json title,url,number,author,labels --template '{{range .}}| {{.title}} | [#{{.number}}]({{.url}}) | [@{{.author.login}}](https://github.com/{{.author.login}}) | {{range .labels}}`{{.name}}` {{end}} | {{"\n"}}{{end}}' | sort -
}

readonly usage="LIMIT=100 BRANCH=master START_DATE=yyyy-MM-dd END_DATE=yyyy-MM-dd $(basename "$0")"
[ "$1" = "-h" -o "$1" = "--help" ] && echo -e "$usage" && exit 0

if [ "$1" = "daily" ]
    readonly branches=$(echo "$BRANCH" | sed "s/,/ /g")
    readonly search_date=$(date +%Y-%m-%d)
    START_DATE="$search_date"
    END_DATE="$search_date"
    for branch in ${branches[@]}
    do
        echo -e "\n$branch"
        BRANCH=$branch
        root_dir="daily/$BRANCH"
        mkdir -p "$root_dir"
        body=$(fetch)
        echo "$body"
        echo "$body" > "$root_dir/$search_date.md"
    done
then
    fetch
fi
