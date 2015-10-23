#!/usr/bin/env python
# -*- coding: utf-8 -*-

import threading
import pytest

import threadpool


def run_threads(threadnum, func, args, callback=None):
    """Convenience wrappet to spawn multiple threads"""
    def exp_callback(request, exc_info):
        pass

    pool = threadpool.ThreadPool(threadnum)

    for req in threadpool.makeRequests(func, args, callback, exp_callback):
        pool.putRequest(req)

    while True:
        try:
            pool.poll()
        except KeyboardInterrupt:
            break
        except threadpool.NoResultsPending:
            break

    if pool.dismissedWorkers:
        pool.joinAllDismissedWorkers()


@pytest.mark.xfail(raises=AttributeError)
def test_run_threads():
    num_threads = 3
    num_calls = 10000
    results = []
    lock = threading.Lock()

    def cb(req, res):
        with lock:
            results.append(res)

    def func(i):
        return i

    run_threads(num_threads, func, list(range(num_calls)), cb)
    assert len(results) == num_calls


def task1(arg):
    print(arg)


def dispatcher(arg):
    args = list(range(50))
    run_threads(3, task1, args)


def test_threads_run_threads():
    args = list(range(50))
    run_threads(3, dispatcher, args)


if __name__ == '__main__':
    test_run_threads()
