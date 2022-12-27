.PHONY: install xsession
install: xmonad art startup

xmonad-link:
	ln -s $(PWD)/.xmonad $(HOME)/.xmonad

xmonad: xmonad-link
	xmonad --recompile

art:
	mkdir -p ~/Documents/Art
	cp ocean_park_114.jpg ~/Documents/Art/

xsession:
	sudo cp myXmonad.desktop /usr/share/xsessions/

startup:
	ln -s $(PWD)/.xinitrc $(HOME)/.xinitrc
	ln -s $(PWD)/exwm.start $(HOME)/exwm.start
	ln -s $(PWD)/xmonad.start $(HOME)/xmonad.start

config-dir:
	mkdir -p $(HOME)/.config

polybar: config-dir
	ln -s $(PWD)/.config/polybar $(HOME)/.config/polybar

conky: config-dir
	ln -s $(PWD)/.config/conky $(HOME)/.config/conky

rofi: config-dir
	ln -s $(PWD)/.config/rofi $(HOME)/.config/rofi

config : config-dir polybar conky rofi

clean-links:
	rm -f $(HOME)/exwm.start
	rm -f $(HOME)/xmonad.start
	rm -f $(HOME)/.xinitrc
	rm -f $(HOME)/.config/polybar
	rm -f $(HOME)/.config/conky
	rm -f $(HOME)/.config/rofi
	rm -f $(HOME)/.xmonad

clean: clean-links

all: xmonad art startup xsession config
