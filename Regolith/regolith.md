Install:
https://regolith-linux.org/download/

```
$ sudo add-apt-repository ppa:regolith-linux/release
$ sudo apt install regolith-desktop
```

The restart and login using regolith desktop.




Then install additional taskbar modules

Set up battery indicator. First, [stage config file](https://regolith-linux.org/docs/howto/stage-configs/)
Add battery package. See all packages with:

See: https://regolith-linux.org/docs/howto/add-remove-blocklets/

```
apt search i3xrocks-
```

See many options to add indicators to taskbar
Then install battery package and other indicators on taskbar

```
sudo apt install i3xrocks-battery i3xrocks-time i3xrocks-volume
i3xrocks-wifi
```

The press super-shift-r to reset regolith



Problem with terminal windows so changed compositor to *xcompmgr*,
https://github.com/regolith-linux/regolith-desktop/issues/370
https://regolith-linux.org/docs/customize/compositors/

```
# sudo apt install regolith-compositor-xcompmgr
```

The log out and back in (i3 reset will no do)

Then, noticed some apps like Gnome desktop tools like image viewer and calendar do not highlight their borders when in focus. I cannot see the border color change when I set he orientation of the next window. 
I tried forcing a border around GTK apps:
https://askubuntu.com/questions/976030/how-to-enable-add-window-borders-in-17-10-18-04



Configuration:
-------------
regolith config file

https://github.com/regolith-linux/regolith-desktop/wiki/Customize


Changing wifi setting ool
https://regolith-linux.org/docs/howto/override-xres/#example---launch-nm-applet-when-i3-starts

Also, when waking up from sleep, lock screen does not engage until I press a key, so you can see my screen and all information on it when you open the lid.

Also, wifi does not always re-connect when waking up from sleep. And, cannot switch networks. WiFi settings will not work properly.





```
$ mkdir -p ~/.config/regolith/i3
$ cp /etc/regolith/i3/config ~/.config/regolith/i3/config
```

Then add i3xrocks



Customizing regolith

```
$ echo "i3-wm.program.1: /usr/bin/nm-applet" >> ~/.config/regolith/Xresources
$ echo "i3-wm.bar.trayoutput:primary" >> ~/.config/regolith/Xresources
$ echo "i3-wm.workspace.01.name:    1:<span font_desc='JetBrains Mono Medium 13'> Terminals </span>" >> ~/.config/regolith/Xresources
$ echo "i3-wm.gaps.inner.size: 0" >> ~/.config/regolith/Xresources
```
 logout and back in


Window borders:  https://github.com/regolith-linux/regolith-desktop/issues/210


Some articles about customizing regolith
https://craftcodecrew.com/regolith-quickstart-creating-a-custom-theme/
https://dev.to/funkyidol/regolith-linux-my-descent-into-mouse-less-navigation-17dc


## CONCLUSION:

An acceptable solution. Enable maximum use of desktop space by normal windows.  Combination of i3 desktop environment and Gnome tools is best of both worlds. Issues with screen highlighting are not deal breakers. Ability to install on top of Ubuntu and use when you want is attractive.

You have to learn the keyboard shortcuts so I created a wallpaper that displays them. You can also see the shortcut menu on the right when you click `Super-Shift-?`.

Overall, it's inspired me to learn the keyboard shortcuts in both Ubuntu and in regolith. Managing windows from the keyboard reduces strain on my wrist -- especially on my mouse-hand.


# Stabdard Ubuntu

install gnome tweaks

```
$ sudo apt install gnome-tweaks
```

Install gnome shell extensions

```
$ sudo apt install gnome-shell-extensions
```

Log out and log in again

Install other Gnome shell extensions
https://linuxconfig.org/how-to-install-gnome-shell-extensions-on-ubuntu-20-04-focal-fossa-linux-desktop

Open Firefox and go to the . [Gnome shell extensions add-on page](https://addons.mozilla.org/en-US/firefox/addon/gnome-shell-integration/). Click on the *Add to Firefox* button.


Then install the chrome gnome shell host connector.
```
$ sudo apt install chrome-gnome-shell
```

(it is already installed -- not sure which package pulled it down)

Click pn the Gnome extension icon in the Firefox navigation bar

In the window that appears, search for your extension. I searched for "title bar". Options that looked good were:

* GTK Title Bar
* No Title Bar - Forked 

Click on the )n/Off slider in the top right corner to install the extension. Note that they are automatically enabled in Gnome Tweaks.

Note, this copies file into the folder: *~/.local/share/gnome-shell/extensions*. You could also do this manually if you want.

Click on *Setings* icon next to the *GTK Title Bar* extension. In the next window, set *Hide windows titlebars* to *Always*.

Click on *Setings* icon next to the *No Title Bar - Forked* extension.  Chane the *Window control buttons* optio to *Within status area*.

Hmmm. When I minimize the tweaks app, the title bar returns on Firefox (but not VScode). Maximizing Firefox still hides the title bar. So, inconsistent operation.

Disabling *No Title Bar - Forked* solved the issue but then I have no window control button in the panel. and I need to use keyboard shortcuts.


Next: Try "Pixel Saver"

This worked for the maximized windows only (but so did the above extensions so no improvement)

Next: try "No Title Bar" by franglais125

Does not work at all.

CONCLUSION: Gnome extension save a bit of space, but in an inconsistent way and it's very confusing to pick the right one.
Also: loss of the title barlosessome functionality, like double-clicking on the title bar to maximize or restore a window, and using the hide and maximizw/restore buttons. This means you need to learn keyboard shortcuts to manage windows. 




# Pop OS Shell

https://github.com/pop-os/shell

https://www.forbes.com/sites/jasonevangelho/2020/04/16/watch-heres-how-window-auto-tiling-works-in-pop-os-2004/#cde82eb16ec0
X
https://www.linuxuprising.com/2020/05/how-to-install-pop-shell-tiling.html

git clone https://github.com/pop-os/shell.git
cd shell
sudo apt install node-typescript make git

$ tsc -v
Version 3.9.5

sh rebuild.sh

$ sudo apt install pop-shell-shortcuts

Did not work well with Ubuntu theme. Errors in terminal window. 

Switched to Pop OS live CD. Looked great. But still uses up too much vertical screen space. There appears to be a planned option to remove the window title bar but it does not show up in the actual UI (yet).

CONCLUSION: Does not save *any* screen space. Future versions might enable hiding the title bar so I'll check this again in the future. Enables keyboard shortcuts to manage window tiling -- and even normal windows. But, now you have to learn the shortcuts.