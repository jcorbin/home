#!/bin/sh

for part in $(~/bin/deporder -f ~/.profile.d); do
	. $part
done
