

GIT_USER_CONFIG := $(HOME)/.gitconfig_user
USER := José Guilherme Vanz
EMAIL := jvanz@jvanz.com
SIGKEY := 4159E08B20565EF1

all: uninstall install links config

uninstall: 
	rm -rf ~/.vim
	rm -f ~/.tmux.conf
	rm -f ~/$(GIT_USER_CONFIG)
	rm -f ~/.gitconfig

install: 
	sudo zypper install -y \
		autoconf \
		automake \
		clang \
		ctags \
		curl \
		deja-dup \
		doxygen \
		flatpak \
		gcc \
		gcc-c++ \
		gdb \
		git-core \
		git-email \
		go \
		make \
		meson \
		neomutt \
		ninja \
		osc \
		python-pip \
		python3-pip \
		strace \
		tmux \
		unzip \
		valgrind \
		vim \
		wget
	
	pip3 install --user meson

links:
	ln -s $(PWD)/vim $(HOME)/.vim
	ln -s $(PWD)/tmux.conf $(HOME)/.tmux.conf
	ln -s $(PWD)/gitconfig $(HOME)/.gitconfig

config:
	echo "source $(PWD)/bashrc" >> $(HOME)/.bashrc
	# Configure git
	git config -f $(GIT_USER_CONFIG) user.name "$(USER)"
	git config -f $(GIT_USER_CONFIG) user.email "$(EMAIL)"
	git config -f $(GIT_USER_CONFIG) user.signkey "$(SIGKEY)"
	git config -f $(GIT_USER_CONFIG) commit.gpgsign true

