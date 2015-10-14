#!/bin/bash

# make_release.sh - automates steps to build a threadpool release

# generates documentation files and packages distribution archive

if [ "x$1" = "x-f" ]; then
    FINAL=yes
    shift
fi

echo "Before you go ahead, check that the version numbers in README.txt, "
echo "and src/release.py are correct!"
echo
echo "Press ENTER to continue, Ctrl-C to abort..."
read
echo

GIT_URL="git@github.com:SpotlightKid/threadpool.git"
PROJECT_NAME=$(python2 -c 'execfile("src/release.py"); print name')
VERSION=$(python2 -c 'execfile("src/release.py"); print version')
HOMEPAGE=$(python2 -c 'execfile("src/release.py"); print url')

VENV="./venv"
RST2HTML_OPTS='--stylesheet-path=rest.css --link-stylesheet --input-encoding=UTF-8 --output-encoding=UTF-8 --language=en --no-xml-declaration --date --time'

if [ ! -d "$VENV" ]; then
    virtualenv -p python2.7 --no-site-packages "$VENV"
    source "$VENV/bin/activate"
    pip install Pygments docutils "epydoc>3.0" wheel
    cwd="$(pwd)"
    ( cd $VENV/lib/python2.7/site-packages/epydoc ; patch -p0 -i $cwd/misc/epydoc.patch ; )
else
    source "$VENV/bin/activate"
fi


# Create HTML file with syntax highlighted source
echo "Making colorized source code HTML page..."
pygmentize  -P full -P cssfile=hilight.css -P title=threadpool.py \
    -o doc/threadpool.py.html src/threadpool.py
# Create API documentation
echo "Generating API documentation with epydoc..."
epydoc --debug -v -n Threadpool -o doc/api \
  --url "$HOMEPAGE" \
  --no-private --docformat restructuredtext \
  src/threadpool.py
# Create HTMl version of README
echo "Creating HTML version of README..."
rst2html $RST2HTML_OPTS README.rst >doc/index.html

# Build distribution packages
if [ "x$FINAL" != "xyes" ]; then
    python setup.py bdist_egg bdist_wheel sdist --formats=zip,bztar
    if [ "x$1" = "xupload" ]; then
        ./tools/upload.sh
    fi
else
    # Check if everything is commited
    GIT_STATUS=$(git status -s)
    if [ -n "$GIT_STATUS" ]; then
        echo "Git is not up to date. Please fix." 2>&1
        exit 1
    fi

    # and upload & register them at the Cheeseshop if "-f" option is given
    python setup.py egg_info -RDb "" bdist_egg bdist_wheel sdist \
        --formats=zip,bztar register upload
    ret=$?
    # tag release in the Git repo
    if [ $ret -eq 0 ]; then
       git tag -m "Tagging $PROJECT_NAME release $VERSION" $VERSION
    fi
    # update web site
    ./tools/upload.sh -f
fi
