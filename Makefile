.PHONY: install
install: xmonad art startup

xmonad:
	ln -s $(PWD)/.xmonad $(HOME)/.xmonad
	xmonad --recompile

art:
	mkdir -p ~/Documents/Art
	cp ocean_park_114.jpg ~/Documents/Art/

.PHONY: xsession
xsession:
	sudo cp myXmonad.desktop /usr/share/xsessions/

startup:
	ln -s $(PWD)/.xinitrc $(HOME)/.xinitrc
	ln -s $(PWD)/xmonad.start $(HOME)/xmonad.start

polybar:
	mkdir -p $(HOME)/.config
	ln -s $(PWD)/.config/polybar $(HOME)/.config/polybar

conky:
	mkdir -p $(HOME)/.config
	ln -s $(PWD)/.config/conky $(HOME)/.config/conky

rofi:
	mkdir -p $(HOME)/.config
	ln -s $(PWD)/.config/rofi $(HOME)/.config/rofi

clean:
	rm -f $(HOME)/xmonad.start
	rm -f $(HOME)/.xinitrc
	rm -f $(HOME)/.xmonad

all: xmonad art startup xsession polybar conky rofi
