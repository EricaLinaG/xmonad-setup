.PHONY: install
install: xmonad art startup

xmonad:
	ln -s .xmonad $(HOME)/.xmonad
	xmonad --recompile

art:
	mkdir -p ~/Documents/Art
	cp ocean_park_114.jpg ~/Documents/Art/

.PHONY: xsession
xsession:
	sudo cp myXmonad.desktop /usr/share/xsessions/

startup:
	ln -s .xinitrc $(HOME)/.xinitrc
	ln -s xmonad.start $(HOME)/xmonad.start

polybar:
	mkdir -p $(HOME)/.config
	ln -s .config/polybar 	$(HOME)/.config/polybar

conky:
	mkdir -p $(HOME)/.config
	ln -s .config/conky 	$(HOME)/.config/conky

rofi:
	mkdir -p $(HOME)/.config
	ln -s .config/rofi 	$(HOME)/.config/rofi

all: xmonad art startup xsession polybar conky rofi
