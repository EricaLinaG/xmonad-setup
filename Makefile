.PHONY: install


xmonad:
	ln -s .xmonad $(HOME)/.xmonad
	xmonad --recompile

.PHONY: xsession
art:
	mkdir -p ~/Documents/Art
	cp ocean_park_114.jpg ~/Documents/Art/

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

all: xmonad art xsession polybar conky rofi startup
