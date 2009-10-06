#!/usr/bin/env python

from setuptools import setup

execfile('src/release.py')

setup(
    name=name,
    version=version,
    description=description,
    long_description=long_description,
    keywords=keywords,
    author=author,
    author_email=author_email,
    license=license,
    url=url,
    download_url=download_url,
    classifiers=classifiers,
    platforms=platforms,
    py_modules  = ['threadpool'],
    package_dir = {'': 'src'},
)
