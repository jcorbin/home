#!/usr/bin/python

import shlex
from subprocess import CalledProcessError, list2cmdline, PIPE, Popen

def run(cmd, wait=True, ok_retcodes=(0,), **kwargs):
    if isinstance(cmd, unicode):
        cmd = cmd.encode('ascii')
    if isinstance(cmd, str):
        cmdstr = cmd
        cmd = shlex.split(cmd)
    else:
        cmdstr = list2cmdline(cmd)
    p = Popen(cmd, **kwargs)
    p.cmdstr = cmdstr
    p.cmd = cmd
    if wait:
        retcode = p.wait()
        if retcode not in ok_retcodes:
            raise CalledProcessError(retcode, p.cmdstr)
    return p

run_line = lambda cmd, **kwargs: run(
    cmd, stdout=PIPE, **kwargs).stdout.readline().strip()

def revs(*revs):
    if not len(revs): return None
    cmd = ('git', 'rev-parse') + revs
    p = run(cmd, stdout=PIPE)
    if len(revs) == 1:
        return p.stdout.readline().strip()
    else:
        return (rev.strip() for rev in p.stdout)

def shortrevs(*rs):
    for rev in revs(*rs):
        yield rev[:7]


import dateutil.parser
import re

def match_in_file(regex, f):
    if isinstance(regex, basestring):
        regex = re.compile(regex)
        for line in f:
            match = regex.search(line)
            if match:
                yield match.groups()

regex = r'\[(.+?)\] "GET /~jcorbin/forwork/(\w+)-([0-9a-fA-F]{7})-([0-9a-fA-F]{7})\.sh\.gz'

import os
import sys
os.chdir(os.path.dirname(os.path.realpath(sys.argv[0])))

remote = 'drop'

with open('/var/log/lighttpd/access.log', 'r') as f:
    for when, ref, a, b in match_in_file(regex, f):
        if ref == 'pack': ref = 'master'
        last, sent = shortrevs(
            remote + '/' + ref,
            'for/' + remote + '/' + ref)
        if last == a:
            run(('git', 'shell-pack', 'ack', remote, ref, b))
