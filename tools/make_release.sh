#!/bin/bash

# make_release.sh - automates steps to build a threadpool release

# generates documentation files and packages distribution archive

if [ "x$1" = "x-f" ]; then
    FINAL=yes
    shift
fi

echo "Before you go ahead, check that the version numbers in README.txt, "
echo "and setup.py are correct!"
echo
echo "Press ENTER to continue, Ctrl-C to abort..."
read
echo

SVN_BASE_URL="svn://chrisarndt.de/projects"
PROJECT_NAME=$(python -c 'execfile("src/release.py"); print name')
VERSION=$(python -c 'execfile("src/release.py"); print version')
HOMEPAGE=$(python -c 'execfile("src/release.py"); print url')

VENV="../venv"
RST2HTML_OPTS='--stylesheet-path=rest.css --link-stylesheet --input-encoding=UTF-8 --output-encoding=UTF-8 --language=en --no-xml-declaration --date --time'

if [ ! -d "$VENV" ]; then
    virtualenv --no-site-packages "$VENV"
    source "$VENV/bin/activate"
    easy_install Pygments docutils "epydoc>3.0"
else
    source "$VENV/bin/activate"
fi


# Create HTML file with syntax highlighted source
pygmentize  -P full -P cssfile=hilight.css -P title=threadpool.py \
    -o doc/threadpool.py.html src/threadpool.py
# Create API documentation
epydoc -v -n Threadpool -o doc/api \
  --url "$HOMEPAGE" \
  --no-private --docformat restructuredtext \
  src/threadpool.py
# Create HTMl version of README
rst2html.py $RST2HTML_OPTS README.txt >doc/index.html

# Build distribution packages
if [ "x$FINAL" != "xyes" ]; then
    python setup.py bdist_egg sdist --formats=zip,bztar
    if [ "x$1" = "xupload" ]; then
        ./tools/upload.sh
    fi
else
    # Check if everything is commited
    SVN_STATUS=$(svn status)
    if [ -n "$SVN_STATUS" ]; then
        echo "SVN is not up to date. Please fix." 2>&1
        exit 1
    fi

    # and upload & register them at the Cheeseshop if "-f" option is given
    python setup.py egg_info -RDb "" bdist_egg sdist --formats=zip,bztar \
        register upload
    ret=$?
    # tag release in SVN
    if [ $ret -eq 0 ]; then
        svn copy "$SVN_BASE_URL/$PROJECT_NAME/trunk" \
          "$SVN_BASE_URL/$PROJECT_NAME/tags/$VERSION" \
           -m "Tagging $PROJECT_NAME release $VERSION"
    fi
    # update web site
    ./tools/upload.sh -f
fi
