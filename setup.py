#!/usr/bin/env python
# -*- coding: utf-8 -*-

from setuptools import setup


with open('src/release.py') as f:
    exec(compile(f.read(), 'src/release.py', 'exec'))

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
