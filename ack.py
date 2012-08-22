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

import bisect
def history_entries(packid):
    with open('pack_history', 'r') as f:
        for line in f:
            rec = line.rstrip('\r\n').split()
            if rec[0] == packid:
                yield rec[1], tuple(rec[2:])

regex = r'\[(.+?)\] "GET /~jcorbin/(\w+)/shell-pack-([0-9a-fA-F]{40})\.sh\.gz'

import os
import sys
os.chdir(os.path.dirname(os.path.realpath(sys.argv[0])))

with open('/var/log/lighttpd/access.log', 'r') as f:
    acked = set()
    for when, remote, packid in match_in_file(regex, f):
        for history_remote, refspecs in history_entries(packid):
            if history_remote != remote: continue
            for refspec in refspecs:
                if (remote, refspec) in acked: continue
                rev, ref = refspec.split(':', 1)
                run(('git', 'shell-pack', 'ack', remote, ref, rev))
                acked.add((remote, refspec))
