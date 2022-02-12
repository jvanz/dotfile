

GIT_USER_CONFIG := $(HOME)/.gitconfig_user
USERNAME := José Guilherme Vanz
EMAIL := jvanz@jvanz.com
SIGKEY := 4159E08B20565EF1
GIT_SUSE_CONFIG := $(HOME)/.gitconfig_suse

REPOSITORIES_HOME ?= $(HOME)/repositories

SERVICE_NAME=sync_brain
SYSTEMD_SERVICE_FILE_DIR ?= $(HOME)/.config/systemd/user

all: install reconfigure

reconfigure: uninstall create-user-systemd-dir links config 

uninstall: 
	rm -f ~/.tmux.conf rm -f ~/$(GIT_USER_CONFIG)
	rm -f ~/.gitconfig
	rm -f ~/.config/osc
	rm -f ~/.zshrc
	rm -f ~/.zsh

zypper-packages:
	sudo zypper install -y \
		anki \
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
		golang-packaging \
		jq \
		make \
		meson \
		neovim \
		ninja \
		osc \
		podman \
		python-pip \
		python3-docker-compose \
		python3-pip \
		quilt \
		secret-tool \
		strace \
		texlive-dvisvgm \
		tmux \
		unzip \
		valgrind \
		vim \
		virt-install \
		wget \
		zsh

python-packages:
	pip3 install --user meson

.PHONY: flatpak-apps
flatpak-apps:
	flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	flatpak install --user --app -y Obsidian Zotero Discord Todoist Slack

install: zypper-packages python-packages flatpak-apps

links:
	ln -s -f $(PWD)/tmux.conf $(HOME)/.tmux.conf
	ln -s -f $(PWD)/gitconfig $(HOME)/.gitconfig
	ln -s -f $(PWD)/osc ~/.config/osc
	ln -s -f $(PWD)/zshrc ~/.zshrc
	ln -s -f $(PWD)/vim ~/.config/nvim

git-config: 
	# Configure git
	git config -f $(GIT_USER_CONFIG) user.name "$(USERNAME)"
	git config -f $(GIT_USER_CONFIG) user.email "$(EMAIL)"
	git config -f $(GIT_USER_CONFIG) user.signingkey "$(SIGKEY)"
	git config -f $(GIT_USER_CONFIG) commit.gpgsign true
	ln -s -f $(PWD)/gitconfig.suse $(GIT_SUSE_CONFIG) 

bash-config:
	echo "source $(PWD)/bashrc" >> $(HOME)/.bashrc

gnome-config:
	# Configure gnome
	gsettings set org.gnome.shell.app-switcher current-workspace-only true

config: bash-config git-config gnome-config


systemd-reload-daemon:
	systemctl --user daemon-reload

create-user-systemd-dir:
	mkdir -p  ~/.config/systemd/user

.PHONY: clean-brain-sync-service
clean-brain-sync-service: 
	- rm $(SYSTEMD_SERVICE_FILE_DIR)/$(SERVICE_NAME).service
	- rm $(SYSTEMD_SERVICE_FILE_DIR)/$(SERVICE_NAME).timer

.PHONY: brain-sync-service
brain-sync-service: clean-brain-sync-service
	cp $(PWD)/oneshoot-service.service $(SYSTEMD_SERVICE_FILE_DIR)/$(SERVICE_NAME).service
	sed -i "s/{{DESCRIPTION}}/Sync brain repository/" $(SYSTEMD_SERVICE_FILE_DIR)/$(SERVICE_NAME).service
	sed -i "s/{{DOCUMENTATION}}//" $(SYSTEMD_SERVICE_FILE_DIR)/$(SERVICE_NAME).service
	sed -i "s;{{WANTEDBY}};default.target;" $(SYSTEMD_SERVICE_FILE_DIR)/$(SERVICE_NAME).service
	sed -i "s;{{ENVIRONMENT}};Environment=\"REPOSITORY_PATH=$(REPOSITORIES_HOME)/brain\";" $(SYSTEMD_SERVICE_FILE_DIR)/$(SERVICE_NAME).service
	sed -i "s;{{EXECSTART}}; $(HOME)/.local/bin/repository_sync;" $(SYSTEMD_SERVICE_FILE_DIR)/$(SERVICE_NAME).service
	cp $(PWD)/oneshoot-service.timer $(SYSTEMD_SERVICE_FILE_DIR)/$(SERVICE_NAME).timer
	sed -i "s/{{DESCRIPTION}}/Sync brain repository timer/" $(SYSTEMD_SERVICE_FILE_DIR)/$(SERVICE_NAME).timer
	sed -i "s;{{ONBOOTSEC}};10m;" $(SYSTEMD_SERVICE_FILE_DIR)/$(SERVICE_NAME).timer
	sed -i "s;{{ONCALENDAR}};hourly;" $(SYSTEMD_SERVICE_FILE_DIR)/$(SERVICE_NAME).timer
	sed -i "s;{{UNIT}};$(SERVICE_NAME).service;" $(SYSTEMD_SERVICE_FILE_DIR)/$(SERVICE_NAME).timer
	sed -i "s/{{WANTEDBY}}/default.target/" $(SYSTEMD_SERVICE_FILE_DIR)/$(SERVICE_NAME).timer
	systemctl --user enable $(SYSTEMD_SERVICE_FILE_DIR)/$(SERVICE_NAME).timer
	systemctl --user start $(SERVICE_NAME).timer

.PHONY: brain
brain: brain-sync-service systemd-reload-daemon
	git clone git@github.com:jvanz/brain.git $(REPOSITORIES_HOME)/brain
