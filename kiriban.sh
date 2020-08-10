#!/bin/bash

# 最大ページ数
max_pages=20

# 何日前まで遡るか
days=7

# 連絡先の分かる情報
user_agent="https://github.com/koizuka/kiriban"

if [[ "$1" == "" ]]; then
  echo "タグを指定してください" >&2
  exit 1
fi
TAGS=$@


NOW=$(date +%s)
LIMIT_TIME=$(( $NOW - $days * (24*60*60) ))

function urlencode() {
  jq -n --arg tag "$1" -r '$tag | @uri'
}

function get_tags_timeline() {
  TAG=$1
  NEXT=$2
  URL="https://www.nicovideo.jp/api/tagrepo/v2/timeline?tags=$(urlencode $TAG)"
  if [[ "$NEXT" != "" ]]; then
    URL="$URL&untilId=$NEXT"
  fi
  curl -A "$userAgent" -s "$URL"
}

function time_to_iso8601() {
  date -d @$1 --iso-8601=seconds
}

echo "$days 日前まで探索します。最大 $max_pages ページ" >&2

[[ -d ./log ]] || mkdir log

for TAG in $TAGS; do
  echo "tag: $TAG" >&2
  NEXT=
  temps=
  for i in $(seq 1 $max_pages); do
    echo $i/$max_pages >&2
    FILENAME=log/$TAG.$i.json
    get_tags_timeline $TAG $NEXT| jq . > $FILENAME
    NUMOBJS=$(jq -r '.data | length | tonumber' $FILENAME)
    if [[ $NUMOBJS -eq 0 ]]; then
      rm $FILENAME
      break
    fi

    OLDEST_TIME=$(date -d "$(jq -r '.data[-1].createdAt' $FILENAME)" +%s)
    echo "$(time_to_iso8601 $OLDEST_TIME) まで" >&2

    tempfile=log/temp.$i.json
    jq '[.data[] |select(.topic == \"nicovideo.user.video.kiriban.play\" ) | {date:.createdAt, video: {id:.video.id, title:.video.title}, viewCount:.actionLog.viewCount}]' $FILENAME > $tempfile

    NEXT="&untilId=$(jq -r .meta.minId $FILENAME)"
    temps="$temps $tempfile"

    if [[ $OLDEST_TIME -lt $LIMIT_TIME ]]; then
      break
    fi
    sleep 1 # サーバーにやさしく
  done
  jq -n '{tag: \"'$TAG'\", kiriban:[inputs[]], foundSince: \"'$(time_to_iso8601 $OLDEST_TIME)'\"}' $temps > $TAG.json
  rm $temps
  echo generated: $TAG.json
done
