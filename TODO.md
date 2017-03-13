# more parts for .profile

- homebrew token?

# more zsh

- prompt
- terminal title

# README

- modern "portability"
  - BSD/Darwin (Mac OS)
  - GNU/Darwin (Mac OS with some GNU subversion)
  - GNU/Linux
- bash is the least common denominator, not posix sh
- unification of zsh and bash: shared profile
  - corollary: sanified bash profile vs rc 
- vi style keybinds in the shell
- unified (Neo)Vim rc with self-installing vim-plug
- on arrayutil and *PATHs
- iteration, e.g. vimrc affordance

# MOVING

Mark `{TODO,README,MOVING}.md` to be ignored in future merges

# Makefile?

Maybe provide a makefile for common workflows, e.g. initial setup (like brewing).

submodule init

# borg

https://github.com/mrzool/dotfiles/blob/master/readline/.inputrc
http://www.pixelbeat.org/scripts/l
https://github.com/mattjj/my-oh-my-zsh/blob/master/terminal.zsh

TIME_STYLE

+stty -ixon -ixoff


# compilation ala deporder

1. replace manual ordering list with deporder
2. add compilation id support to deporder
3. use profile compilation id instead of _PROFILE_LOADED
4. write a "reload if outdated" function; maybe compiler defined or afforded
5. use that as the basis for autorelead

# runtime support?

golang, java, node, python, etc

