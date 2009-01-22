from __future__ import with_statement

import os
import re

def hostSpecificitySort(a,b):
	la=len(a.spec)
	lb=len(b.spec)
	if lb == la:
		return cmp(a.name, b.name)
	else:
		return cmp(lb, la)

class Config:
	System = '/etc/ssh/ssh_config'
	User = os.path.expanduser('~/.ssh/config')

	rSkip = re.compile("^\s*(?:#.*)?$")
	rDirective = re.compile("^\s*([^\s]+)(?:(?:\s*=\s*)|\s+)(.+)$")

	def __init__(self):
		self.hosts = []
		self.options = {}
		self.parse(Config.System)
		self.parse(Config.User)

	def parse(self, file):
		with open(file) as f:
			host = None
			hostopt = {}
			for line in f:
				m=Config.rDirective.match(line)
				if m is not None:
					(key, value) = m.group(1,2)
					if key == 'Host':
						if host is not None:
							self.hosts.append(ConfigHost(host, hostopt))
							hostopt = {}
						host = value
					else:
						if host is None:
							self.options[key] = value
						else:
							hostopt[key] = value
			if host is not None:
				self.hosts.append(ConfigHost(host, hostopt))

	def namedHosts(self):
		r=[]
		for h in self.hosts:
			if h.name is not None:
				r.append(h)
		return r

	def matchHost(self, name):
		r=[]
		for h in self.hosts:
			if h.match(name):
				r.append(h)
		r.sort(hostSpecificitySort)
		return r

	def hostOption(self, host, opt):
		hosts=self.matchHost(host)
		for h in hosts:
			if opt in h.opt:
				return h.opt[opt]
		return None

class ConfigHost:
	def __init__(self, spec, opt):
		self.spec = spec
		self.opt = opt
		self.name = None
		rMatch=[]
		rNotMatch=[]

		lSpec = re.split("(?:(?:,\s*)|\s+)", self.spec)
		if len(lSpec) > 0:
			rStar = re.compile('\*')
			rQues = re.compile('\?')

			if not rStar.search(lSpec[0]) and not rQues.search(lSpec[0]):
				self.name = lSpec[0]

			for w in lSpec:
				if w[0] == '!':
					w=w[1:]
					l=rNotMatch
				else:
					l=rMatch
				w=rStar.sub('.*', w)
				w=rQues.sub('.', w)
				l.append(w)

			if len(rMatch) > 1:    rMatch='(?:'+')|(?:'.join(rMatch)+')'
			elif len(rMatch) == 1: rMatch=rMatch[0]
			else:                  rMatch=None
			if rMatch is not None: rMatch=re.compile(rMatch)

			if len(rNotMatch) > 1:    rNotMatch='(?:'+')|(?:'.join(rNotMatch)+')'
			elif len(rNotMatch) == 1: rNotMatch=rNotMatch[0]
			else:                     rNotMatch=None
			if rNotMatch is not None: rNotMatch=re.compile(rNotMatch)

			self.rSpec=(rMatch, rNotMatch)
		else:
			self.rSpec=(None, None)

	def match(self, host):
		if self.rSpec[0] is not None and not self.rSpec[0].match(host):
			return False
		if self.rSpec[1] is not None and self.rSpec[1].match(host):
			return False
		return True
