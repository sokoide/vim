.PHONY: install

IS_TERMUX := $(shell uname -o 2>/dev/null | grep -i Android)

install:
ifeq ($(IS_TERMUX),Android)
	@echo "==== rm/cp for Termux ===="
	rm -rf $(HOME)/.config/nvim
	mkdir -p $(HOME)/.config
	cp -r nvim $(HOME)/.config/nvim
else
	@echo "==== rsync ===="
	mkdir -p $(HOME)/.config
	rsync -av --delete nvim/ $(HOME)/.config/nvim/
endif
	cp .prettierrc.json $(HOME)/
	cp README.md $(HOME)/.config/nvim/
