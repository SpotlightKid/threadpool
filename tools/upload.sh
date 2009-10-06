#!/bin/sh

BASE_DIR="/home/www/chrisarndt.de/htdocs/projects/threadpool"
HOST="chrisarndt.de"
USER="chris"

if [ "x$1" != "x-f" ]; then
    RSYNC_OPTS="-n"
fi

# upload API docs and index.html
rsync $RSYNC_OPTS -av --update --delete \
    --exclude=download \
    --exclude=.svn \
    --exclude=.DS_Store \
    doc/ "$USER@$HOST:$BASE_DIR"

# Upload distribution packages
rsync $RSYNC_OPTS -av --update \
    "--exclude=*.dev*" \
    --exclude=.DS_Store \
    dist/ "$USER@$HOST:$BASE_DIR/download"
