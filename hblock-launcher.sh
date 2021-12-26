#!/bin/bash

# Version:    0.0.3
# Author:     KeyofBlueS
# Repository: https://github.com/KeyofBlueS/hBlock-Launcher
# License:    GNU General Public License v3.0, https://opensource.org/licenses/GPL-3.0

#WARNING: Options in commandline will overcome the configuration below.

# Default path of custom lists
WHITELIST="$HOME/.hblock-whitelist"
BLACKLIST="$HOME/.hblock-blacklist"
SOURCES="$HOME/.hblock-sources"

# Set to "true" to automatically check for hBlock updates
UPDATE=false

# Set to true to not really deploy hBlock and just test THIS script
DEBUG=false

function launch()	{

	# Check if hBlock executable exist and install it if not
	HBLOCK="$(which hblock)"
	if [[ -z "${HBLOCK}" ]]; then
		while true; do
			echo -e "\e[1;33mERROR: hblock executable not found!
	\e[1;35mWould you like to install hBlock?
	(Y)es
	(N)o
	\e[0m"
			read -p "- (Y/n): " testo
			case $testo in
			Y|y)
			{
			echo -e "\e[1;34m## INSTALLING hBlock\e[0m"
			while true;	do
				echo -e "\e[1;33mIn order to perform installation you must grant root permissions\e[0m"
				if sudo -v; then
					break
				else
					echo -e "\e[1;31mPermission denied! Press ENTER to exit or wait 5 seconds to retry\e[0m"
					if read -t 5 _e; then
						exit 1
					fi
				fi
			done
			DIRNAME='scripts'
			URL='https://raw.githubusercontent.com/hectorm/hblock/master/hblock'
			sudo mkdir -p /opt/"${DIRNAME}"
			mkdir -p hblock_tmp
			git clone -b master https://github.com/hectorm/hblock ./hblock_tmp
			sudo mv ./hblock_tmp/hblock /opt/"${DIRNAME}"/hblock.sh
			FOLDERS="$(ls ./hblock_tmp/resources/logo/bitmaps/*.png | grep "logo-shield-transparent-h" | awk -F'logo-shield-transparent-h' '{print $2}' | awk -F'.png' '{print $1}')"
			for folder in ${FOLDERS}
			do
				sudo mkdir -p /usr/local/share/icons/hicolor/"${folder}"x"${folder}"/apps/
				sudo mv ./hblock_tmp/resources/logo/bitmaps/logo-shield-transparent-h"${folder}".png /usr/local/share/icons/hicolor/"${folder}"x"${folder}"/apps/logo-shield-transparent-h"${folder}".png
			done
			rm -rf ./hblock_tmp/
			sudo chown root:root /opt/"${DIRNAME}"/hblock.sh
			sudo chmod 755 /opt/"${DIRNAME}"/hblock.sh
			sudo rm /usr/local/bin/hblock
			sudo ln -s /opt/"${DIRNAME}"/hblock.sh /usr/local/bin/hblock
			exec "${HBLOCK_EXEC}" "${HBOPTIONS}"
			}
			;;
			N|n)
			{
			echo -e "\e[1;34mExiting...\e[0m"
			exit 0
			}
			;;
			*)
			echo -e "\e[1;31m## WRONG KEY.......try to be a little more careful\e[0m"
			;;
			esac
		done
	else
		if [[ -L "${HBLOCK}" ]]; then
			scriptpath="$(readlink -f "${HBLOCK}")"
		else
			scriptpath="${HBLOCK}"
		fi
	fi

	# Check if local hBlock is synced with upstream
	if echo "${UPDATE}" | grep -Eq '^(true|True|TRUE|si|Si|SI)$'; then
		echo -e "\e[1;34mCheck for updates...\e[0m"
	if curl -s github.com > /dev/null; then
		SCRIPT_LINK='https://raw.githubusercontent.com/hectorm/hblock/master/hblock'
		#UPSTREAM_VERSION="$(timeout -s SIGTERM 15 curl -L "${SCRIPT_LINK}" 2> /dev/null | grep "# Version:" | head -n 1)"
		UPSTREAM_VERSION="$(timeout -s SIGTERM 15 curl -L "${SCRIPT_LINK}" 2> /dev/null | grep 'HBLOCK_VERSION=' | awk -F"'" '{print $2}')"
		#LOCAL_VERSION="$(cat "${scriptpath}" | grep "# Version:" | head -n 1)"
		LOCAL_VERSION="$(hblock -v | head -n 1 | awk '{print $2}')"
		REPOSITORY_LINK="$(cat "${scriptpath}" | grep "# Repository:" | head -n 1)"
		if echo "${LOCAL_VERSION}" | grep -q "${UPSTREAM_VERSION}"; then
			echo -e "\e[1;32m
	#${LOCAL_VERSION} (This hBlock is synced with upstream version)\e[0m"
		else
			echo -e "\e[1;33m-----------------------------------------------------------------------------------	
	## WARNING: hBlock is not synced with upstream version, visit:
	\e[1;32m${REPOSITORY_LINK}

	\e[1;33m${LOCAL_VERSION} (locale)
	\e[1;32m${UPSTREAM_VERSION} (upstream)
	\e[1;33m-----------------------------------------------------------------------------------

	\e[1;35mPress ENTER to update hBlock or wait 10 seconds to exit
	\e[1;31m## WARNING: any custom changes will be lost!!!
	\e[0m"
			if read -t 10 _e; then
				echo -e "\e[1;34m	Updating...\e[0m"
				if [[ -z "${scriptfolder}" ]]; then
					scriptfolder="${scriptpath}"
					if ! [[ "${scriptpath}" =~ ^/.*$ ]]; then
						if ! [[ "${scriptpath}" =~ ^.*/.*$ ]]; then
						scriptfolder="./"
						fi
					fi
					scriptfolder="${scriptfolder%/*}/"
					scriptname="${scriptpath##*/}"
				fi
				if timeout -s SIGTERM 15 curl -s -o /tmp/"${scriptname}" "${SCRIPT_LINK}"; then
					if [[ -w "${scriptfolder}${scriptname}" ]] && [[ -w "${scriptfolder}" ]]; then
						mv /tmp/"${scriptname}" "${scriptfolder}"
						chown root:root "${scriptfolder}${scriptname}" > /dev/null 2>&1
						chmod 755 "${scriptfolder}${scriptname}" > /dev/null 2>&1
						chmod +x "${scriptfolder}${scriptname}" > /dev/null 2>&1
					elif which sudo > /dev/null 2>&1; then
						while true; do
							echo -e "\e[1;33mIn order to update you must grant root permissions\e[0m"
							if sudo -v; then
								break
							else
								echo -e "\e[1;31mPermission denied! Press ENTER to exit or wait 5 seconds to retry\e[0m"
								if read -t 5 _e; then
									exit 1
								fi
							fi
						done
						sudo mv /tmp/"${scriptname}" "${scriptfolder}"
						sudo chown root:root "${scriptfolder}${scriptname}" > /dev/null 2>&1
						sudo chmod 755 "${scriptfolder}${scriptname}" > /dev/null 2>&1
						sudo chmod +x "${scriptfolder}${scriptname}" > /dev/null 2>&1
					else
						echo -e "\e[1;31m	Error during update! Permission denied!\e[0m"
					fi
				else
					echo -e "\e[1;31m	Download error!\e[0m"
				fi
				#LOCAL_VERSION="$(cat "${scriptpath}" | grep "# Version:" | head -n 1)"
				LOCAL_VERSION="$(hblock -v | head -n 1 | awk '{print $2}')"
				if echo "${LOCAL_VERSION}" | grep -q "${UPSTREAM_VERSION}"; then
					echo -e "\e[1;34m	Done!\e[0m"
					echo "${0}" "${OPTIONS}"
					echo "${HBLOCK_EXEC}" "${OPTIONS}"
					#exit 0
					exec "${HBLOCK_EXEC}" "${HBOPTIONS}"
				else
					echo -e "\e[1;31m	Error during update!\e[0m"
				fi
			fi
		fi
	fi
	else
		echo -e "\e[1;34m
	Local hBlock version is:\e[0m"
		hblock -v
	fi

	# Check if Whitelist, Blacklist and Sources files exist
	for list in "${WHITELIST}" "${BLACKLIST}" "${SOURCES}"; do
		if [[ ! -e "${list}" ]]; then
			echo -e "\e[1;33mWARNING: ${list} doesn't exist. Creating an empty file...\e[0m"
			touch "${list}"
		fi
	done

	# Check if Whitelist and Blacklist contain valid entries
	for list in "${WHITELIST}" "${BLACKLIST}" "${SOURCES}"; do
		if ! grep -Eoq '[^.]+\.[^.]+$' "${list}"; then
			echo -e "\e[1;33mWARNING: ${list} doesn't contain any valid entry\e[0m"
		fi
	done

	# Use custom AND builtin sources
	while true; do
		SOURCESCUSTOM="$(cat "${SOURCES}" | grep -o "https://raw.githubusercontent.com/hectorm/hmirror/master/data/[^ ]*list.txt" | sort)"
		SOURCESCODED="$(cat "${scriptpath}" | grep -o "https://raw.githubusercontent.com/hectorm/hmirror/master/data/[^ ]*list.txt" | sort)"
		if [[ "${SOURCESCUSTOM}" != "${SOURCESCODED}" ]]; then
			SOURCESCUSTOMCOUNT="$(cat "${SOURCES}" | grep -o "https://raw.githubusercontent.com/hectorm/hmirror/master/data/[^ ]*list.txt" | wc -l)"
			SOURCESCODEDCOUNT="$(cat "${scriptpath}" | grep -o "https://raw.githubusercontent.com/hectorm/hmirror/master/data/[^ ]*list.txt" | wc -l)"
			if [[ "${SOURCESCUSTOMCOUNT}" -lt "${SOURCESCODEDCOUNT}" ]]; then
				SOURCESCOUNTDIFF="$(expr "${SOURCESCODEDCOUNT}" - "${SOURCESCUSTOMCOUNT}")"
				echo -e "\e[1;34m- ${SOURCESCOUNTDIFF} sources added:\e[0m"
				echo "${SOURCESCODED}" | grep -v "${SOURCESCUSTOM}"
			elif [[ "${SOURCESCUSTOMCOUNT}" -gt "${SOURCESCODEDCOUNT}" ]]; then
				SOURCESCOUNTDIFF="$(expr "${SOURCESCUSTOMCOUNT}" - "${SOURCESCODEDCOUNT}")"
				echo -e "\e[1;33m- ${SOURCESCOUNTDIFF} sources removed:\e[0m"
				echo "${SOURCESCUSTOM}" | grep -v "${SOURCESCODED}"
			fi
			echo -e "\e[1;33m- Updating sources list...\e[0m"
			echo "${SOURCESCODED}" >> "${SOURCES}"_temp
			cat "${SOURCES}" | grep -v "https://raw.githubusercontent.com/hectorm/hmirror/master/data/[^ ]*list.txt" >> "${SOURCES}"_temp
			mv "${SOURCES}"_temp "${SOURCES}"
		else
			echo -e "\e[1;34m- Sources list is updated\e[0m"
			break
		fi
	done

	# Show domains blocked before and after hBlock is deployed
	DOMAINSOLD="$(cat /etc/hosts | grep -E "^"${REDIRECT}" " | tr " " "\n" | grep -Ev "^"${REDIRECT}"$|^[[:blank:]]*#|^[[:blank:]]*$")"
	DOMAINSCOUNTOLD="$(echo "${DOMAINSOLD}" | wc -l)"
	if [[ "${DEBUG}" = "false" ]]; then
		hblock -A "${WHITELIST}" -D "${BLACKLIST}" -S "${SOURCES}" ${HBOPTIONS}
	else
		echo -e "\e[1;33m- WARNING: hBlock not really running... just testing THIS script"
		echo hblock -A "${WHITELIST}" -D "${BLACKLIST}" -S "${SOURCES}" ${HBOPTIONS}
	fi
	DOMAINSNEW="$(cat /etc/hosts | grep -E "^"${REDIRECT}" " | tr " " "\n" | grep -Ev "^"${REDIRECT}"$|^[[:blank:]]*#|^[[:blank:]]*$")"
	DOMAINSCOUNTNEW="$(echo "${DOMAINSNEW}" | wc -l)"
	echo -e "\e[1;34m
	Blocked Domains Before:
	${DOMAINSCOUNTOLD}

	Blocked Domains Now:
	${DOMAINSCOUNTNEW}
	\e[0m"

	if [[ "${DOMAINSCOUNTOLD}" -lt "${DOMAINSCOUNTNEW}" ]]; then
		DOMAINSCOUNTDIFF="$(expr "${DOMAINSCOUNTNEW}" - "${DOMAINSCOUNTOLD}")"
		echo -e "\e[1;34m- "${DOMAINSCOUNTDIFF}" more domains count\e[0m"
	elif [[ "${DOMAINSCOUNTOLD}" -gt "${DOMAINSCOUNTNEW}" ]]; then
		DOMAINSCOUNTDIFF="$(expr "${DOMAINSCOUNTOLD}" - "${DOMAINSCOUNTNEW}")"
		echo -e "\e[1;34m- ${DOMAINSCOUNTDIFF} less domains count\e[0m"
	elif [[ "${DOMAINSCOUNTOLD}" = "${DOMAINSCOUNTNEW}" ]]; then
		if [[ "${DOMAINSOLD}" = "${DOMAINSNEW}" ]]; then
			echo -e "\e[1;34m- No changes in domains count\e[0m"
		else
			echo -e "\e[1;34m- No changes in domains count, anyway the following changes have been made:\e[0m"
			diff  <(echo "${DOMAINSOLD}" ) <(echo "${DOMAINSNEW}")
		fi
	fi

	# Creating hblock-launcher.desktop file
	if [[ ! -e $HOME/.local/share/applications/hblock-launcher.desktop ]]; then
		sh -c 'echo "
[Desktop Entry]
Version=1.0
Type=Application
Name=hBlock-Launcher
Comment=Improve your security and privacy by blocking ads, tracking and malware domains.
Icon=/usr/local/share/icons/hicolor/48x48/apps/logo-shield-transparent-h48.png
Exec=hblock-launcher -u
Terminal=true
StartupNotify=true
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;" > $HOME/.local/share/applications/hblock-launcher.desktop'
	fi

	# Exit
	if echo "${AUTO}" | grep -Eq '^(true|True|TRUE|si|Si|SI)$'; then
		exit 0
	else
		echo -e "\e[1;35m
		Press Enter to exit\e[0m"
		if read _e; then
			exit 0
		fi
	fi
}

function givemehelp(){

	echo "
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

	### USAGE
	$ hblock-launcher [options...]

	Options:
	-u, --update	Check for hBlock updates
	-a, --auto	Exit without asking
	-d, --debug	Not really deploy hBlock and just test THIS script
	-h, --help	Show this help

	# hBlock"
	hblock --help
	if echo "$INVALID" | grep -xq "1"; then
		exit 1
	else
		exit 0
	fi
}
HBLOCK_EXEC="${0}"
OPTIONS="$@"
for opt in "$@"; do
	shift
	case "$opt" in
		'--allowlist')			set -- "$@" '-A' ;;
		'--denylist')			set -- "$@" '-D' ;;
		'--sources')			set -- "$@" '-S' ;;
		'--wrap')				set -- "$@" '-W' ;;
		'--output')				set -- "$@" '-O' ;;
		'--header')				set -- "$@" '-H' ;;
		'--footer')				set -- "$@" '-F' ;;
		'--redirection')		set -- "$@" '-R' ;;
		'--template')			set -- "$@" '-T' ;;
		'--comment')			set -- "$@" '-C' ;;
		'--backup')				set -- "$@" '-b' ;;
		'--lenient')			set -- "$@" '-l' ;;
		'--enable-whitelist-regex')		set -- "$@" '-r' ;;
		'--ignore-download-error')		set -- "$@" '-i' ;;
		'--color')				set -- "$@" '-c' ;;
		'--parallel')			set -- "$@" '-p' ;;
		'--quiet')				set -- "$@" '-q' ;;
		'--version')			set -- "$@" '-v' ;;
		'--update')				set -- "$@" '-u' ;;
		'--auto')				set -- "$@" '-a' ;;
		'--debug')				set -- "$@" '-d' ;;
		'--help')				set -- "$@" '-h' ;;
		*)						set -- "$@" "$opt"
	esac
done

while getopts ":A:D:S:W:O:H:F:R:T:C:b:lric:p:qvuadh" opt; do
	case ${opt} in
		A ) if [[ -e "${OPTARG}" ]]; then
			WHITELIST="${OPTARG}"
		else
			echo -e "\e[1;33m - WARNING: \e[1;34m$OPTARG \e[1;33mdoes not exist.
I'll try to use the default one.\e[0m"
		fi
		;;
		D ) if [[ -e "${OPTARG}" ]]; then
			BLACKLIST="${OPTARG}"
		else
			echo -e "\e[1;33m - WARNING: \e[1;34m${OPTARG} \e[1;33mdoes not exist.
I'll try to use the default one.\e[0m"
		fi
		;;
		S ) if [[ -e "${OPTARG}" ]]; then
			SOURCES="${OPTARG}"
		else
			echo -e "\e[1;33m - WARNING: \e[1;34m${OPTARG} \e[1;33mdoes not exist.
I'll try to use the default one.\e[0m"
		fi
		;;
		W ) HBOPTIONS="${HBOPTIONS} -W ${OPTARG}"
		;;
		O ) HBOPTIONS="${HBOPTIONS} -O ${OPTARG}"
		;;
		H ) HBOPTIONS="${HBOPTIONS} -H ${OPTARG}"
		;;
		F ) HBOPTIONS="${HBOPTIONS} -F ${OPTARG}"
		;;
		R ) HBOPTIONS="${HBOPTIONS} -R ${OPTARG}"; REDIRECT="${OPTARG}"
		;;
		T ) HBOPTIONS="${HBOPTIONS} -T ${OPTARG}"
		;;
		C ) HBOPTIONS="${HBOPTIONS} -C ${OPTARG}"
		;;
		b ) HBOPTIONS="${HBOPTIONS} -b ${OPTARG}"
		;;
		l ) HBOPTIONS="${HBOPTIONS} -l ${OPTARG}"
		;;
		r ) HBOPTIONS="${HBOPTIONS} -r ${OPTARG}"
		;;
		i ) HBOPTIONS="${HBOPTIONS} -i ${OPTARG}"
		;;
		c ) HBOPTIONS="${HBOPTIONS} -c ${OPTARG}"
		;;
		p ) HBOPTIONS="${HBOPTIONS} -p ${OPTARG}"
		;;
		q ) HBOPTIONS="${HBOPTIONS} -q ${OPTARG}"
		;;
		v ) HBOPTIONS="${HBOPTIONS} -v ${OPTARG}"
		;;
		u ) UPDATE='true'
		;;
		a ) AUTO='true'
		;;
		d ) DEBUG='true'
		;;
		h ) givemehelp
		;;
		*) INVALID=1; echo -e "\e[1;31m## ERROR: invalid option ${OPTARG}\e[0m"
	esac
done

if [[ -z "${REDIRECT}" ]]; then
	REDIRECT='0.0.0.0'
fi
if echo "${INVALID}" | grep -xq '1'; then
	givemehelp
else
	launch
fi
