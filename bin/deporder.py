#!/usr/bin/env python

import collections
import os


class Graph(object):
    def __init__(self):
        self.G = collections.defaultdict(set)
        self.H = collections.defaultdict(set)

    def update(self, edges):
        for a, b in edges:
            self.G[a].add(b)
            self.H[b].add(a)

    def nodes(self):
        return set(self.G).union(self.H)

    def initial_nodes(self):
        return set(self.G).difference(self.H)

    def terminal_nodes(self):
        return set(self.H).difference(self.G)

    def itertopo(self):
        G = dict((a, set(bs)) for a, bs in self.G.iteritems())
        H = dict((a, set(bs)) for a, bs in self.H.iteritems())
        S = set(G).difference(H)
        while S:
            n = min(S)
            S.remove(n)
            yield n
            for m in G.pop(n, set()):
                H[m].remove(n)
                if not H[m]:
                    S.add(m)
        cycles = dict((node, out) for node, out in G.iteritems() if out)
        if cycles:
            raise CycleError(cycles)


class CycleError(ValueError):
    def __init__(self, graph):
        self.graph = graph
        # TODO: cycle extraction

    def __str__(self):
        return 'cycle involving: ' + repr(self.graph)


def extract_relations(path, name):
    with open(path, 'r') as f:
        for line in f:
            line = line.rstrip('\r\n')
            if not line.startswith('#'):
                break
            fields = line.split(None, 3)
            if len(fields) < 3:
                continue
            rel = fields[1]
            other = fields[2]
            if rel == 'before:':
                yield name, other
            elif rel == 'after:':
                yield other, name


class DependencyGraph(Graph):
    def __init__(self, path):
        super(DependencyGraph, self).__init__()
        self.path = os.path.expanduser(path)
        self.path = os.path.realpath(path)
        self.parts = set()
        for part, path in self.list_parts():
            self.parts.add(part)
            self.update(extract_relations(path, part))
        self.update((node, '.explicit') for node in self.terminal_nodes())
        self.update(('.explicit', node) for node in self.unspecified_parts())

    def list_parts(self):
        for part in os.listdir(self.path):
            if part.startswith('.'):
                continue
            path = os.path.join(self.path, part)
            if not os.path.isfile(path):
                continue
            yield part, path

    def unspecified_parts(self):
        return self.parts.difference(self.nodes())


def main(argv=None):
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('-d', '--dump', action='store_true')
    parser.add_argument('path', default='.', nargs='?')
    args = parser.parse_args(args=argv)
    G = DependencyGraph(args.path)
    parts = [node for node in G.itertopo() if node in G.parts]
    parts = [os.path.join(G.path, part) for part in parts]
    for part in parts:
        print part

if __name__ == '__main__':
    main()
