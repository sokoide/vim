.PHONY: install

install:
	mkdir -p $(HOME)/.config
	rsync -av --delete nvim/ $(HOME)/.config/nvim/
