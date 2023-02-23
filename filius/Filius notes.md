$ flatpak search filius
Name Description                    Application ID        Version Branch Remotes
Fil… Filius is a network simulator… …ftware_filius.Filius 1.14.1  stable flathub
brian@T480:~$ 


$ flatpak install flathub de.lernsoftware_filius.Filius


$ flatpak run de.lernsoftware_filius.Filius

Note that the directories 

'/var/lib/flatpak/exports/share'
'/home/brian/.local/share/flatpak/exports/share'

are not in the search path set by the XDG_DATA_DIRS environment variable, so
applications installed by Flatpak may not appear on your desktop until the
session is restarted.

