#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# test_threadworker.py
#

try:                 # Python 2:
    import sha
    def sha1_new(): return sha.new()
except ImportError:  # Python 3:
    import hashlib
    def sha1_new(): return hashlib.sha1()

import threadpool as tp


def getsha(dummy, data):
    m = sha1_new()
    m.update(data)
    return m.hexdigest()

def print_result(request, result):
    print('"%s" -->\t%s' % (os.path.basename(request.args[0]), result))


if __name__ == '__main__':
    import os, sys

    try:
        topdir = sys.argv[1]
    except IndexError:
        topdir = os.curdir

    files = []
    for dirpath, dirname, filenames in os.walk(topdir):
        for filename in filenames:
            filename = os.path.join(dirpath, filename)
            if os.path.isfile(filename):
                files.append(filename, )

    files.sort()
    main = tp.ThreadPool(10, q_size=50)

    for file in files:
        # Bad approach:
        ## main.putRequest(WorkRequest(getmd5, args=(file, None),
        ##                             callback=print_result))

        # Better approach:
        main.putRequest(tp.WorkRequest(getsha,
                                       args=(file, open(file, 'rb').read()),
                                       callback=print_result))
        try:
            main.poll()
        except tp.NoResultsPending:
            pass

    main.wait()
