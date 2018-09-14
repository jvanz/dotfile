#!/bin/bash

alias lla="ll -a"
alias myip="curl http://ipecho.net/plain; echo"
alias ..="cd .."
alias ...="cd ../.."
alias clipboard='xclip -sel clip'

export MAINTAINER="jvanz@jvanz.com"
export MALLOC_PERTURB_=$(($RANDOM % 255 + 1))
export EDITOR="vim"
export GYP_GENERATORS=ninja
export GOPATH=$HOME/go

export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$HOME/.local/share/pkgconfig:$HOME/.local/lib/pkgconfig

export PATH=$PATH:$HOME/.local/bin:$GOPATH/bin

# consider packages installed in the home directory
export CFLAGS=-I$HOME/.local/include
export LDFLAGS=-L$HOME/.local/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/.local/lib

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi
