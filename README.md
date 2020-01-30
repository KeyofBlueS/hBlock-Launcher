# hBlock-Launcher

# Version:    0.0.1
# Author:     KeyofBlueS
# Repository: https://github.com/KeyofBlueS/hBlock-Launcher
# License:    GNU General Public License v3.0, https://opensource.org/licenses/GPL-3.0

### DESCRIPTION
Adds some functionality to hectorm's hblock:
- Check for hblock updates
- Use custom AND builtin sources
- Show domains blocked before and after hBlock is deployed

### INSTALL
```sh
curl -o /tmp/hblock-launcher.sh 'https://raw.githubusercontent.com/KeyofBlueS/hBlock-Launcher/master/hblock-launcher.sh'
sudo mkdir -p /opt/hBlock-Launcher/
sudo mv /tmp/hblock-launcher.sh /opt/hBlock-Launcher/
sudo chown root:root /opt/hBlock-Launcher/hblock-launcher.sh
sudo chmod 755 /opt/hBlock-Launcher/hblock-launcher.sh
sudo chmod +x /opt/hBlock-Launcher/hblock-launcher.sh
sudo ln -s /opt/hBlock-Launcher/hblock-launcher.sh /usr/local/bin/hblock-launcher
```
### USAGE
```sh
$ hblock-launcher [options...]
```
```
Options:
-u, --update	Check for hBlock updates
-a, --auto	Exit without asking
-d, --debug	Not really deploy hBlock and just test THIS script
-h, --help	Show this help
```

### LIST.TXT
In this repository there is a blocklist you can add to your sources:

https://raw.githubusercontent.com/KeyofBlueS/hBlock-Launcher/master/list.txt
