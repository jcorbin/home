#!/usr/bin/env python

from __future__ import print_function

import argparse
import re
import os
import sys
from subprocess import CalledProcessError, check_call, Popen, PIPE

parser = argparse.ArgumentParser()
parser.add_argument('-S', dest='socket_path')
parser.add_argument('session', nargs='?')
args = parser.parse_args()

tmux_sessiondir = os.path.expanduser('~/.tmux-sessions')

if os.environ.get('COLORTERM') == 'gnome-terminal':
    os.environ['TERM'] = 'xterm-256color'


class tmux(Popen):
    socket_path = args.socket_path

    @classmethod
    def command(cls, *args, **kwargs):
        cmd = ('tmux',)
        if cls.socket_path is not None:
            cmd += ('-S', cls.socket_path)
        cmd += args
        return cmd

    def __init__(self, *args, **kwargs):
        self.command = cmd = self.command(*args, **kwargs)
        try:
            super(tmux, self).__init__(cmd, **kwargs)
        except OSError:
            print('PATH=' + os.environ['PATH'], '+', cmd)
            raise

    def check(self):
        returncode = self.wait()
        if returncode != 0:
            raise CalledProcessError(returncode, self.command)

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        if exc_type is not None and self.poll() is None:
            self.kill()
        returncode = self.wait()
        if exc_type is None and returncode != 0:
            raise CalledProcessError(returncode, self.command)


sessions = set()
if os.path.exists(tmux_sessiondir):
    sessions = set(os.listdir(tmux_sessiondir))

rline = re.compile(r'^(.+?): .*?(\(attached\))?$')
attached, detached = set(), set()
try:
    with tmux('list-sessions', stdout=PIPE) as p:
        for match in (rline.match(str(line).strip()) for line in p.stdout):
            if match:
                session, is_attached = match.groups()
                (attached if is_attached else detached).add(session)
except CalledProcessError:
    pass


def choose_session():
    choices = [(0, None)]
    choices.extend(enumerate(sorted((sessions - attached) | detached), 1))
    fmt = '%%%dd) %%s' % len(str(choices[-1][0]))
    default = 0
    if detached:
        default = next(i for i, c in choices if c == min(detached))
    try:
        while True:
            for i, c in choices:
                if c is None:
                    c = '-- specify --'
                print(fmt % (i, c))
            choice = raw_input(
                'choose session (default %d) >> ' % default
            ) or default
            try:
                choice = int(choice)
                session = choices[choice][1]
            except (IndexError, ValueError):
                continue
            break
        while not session:
            session = raw_input('specify name >> ').strip()
        return session
    except EOFError:
        print()
        return None


if args.session is None and 'default' not in attached:
    args.session = 'default'

if args.session == 'choose':
    args.session = None

if args.session is None:
    args.session = choose_session()
    if args.session is None:
        sys.exit(0)

if tmux('has-session', '-t', args.session).wait() != 0:
    session_script = os.path.join(tmux_sessiondir, args.session)
    if os.path.exists(session_script):
        check_call(session_script)
    else:
        tmux('new-session', '-d', '-s', args.session).check()

cmd = tmux.command('attach-session', '-t', args.session)
os.execlp('tmux', *cmd)
