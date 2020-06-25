#!/bin/bash
: '
  * This is a script to install and configure Deep Web Hosing.
  * created by  Hackuin [@] Ymail [.] com
  * Date: Sunday 21 June 2020 08:20:31 PM IST
  * '

#: Checing if the the script is not run by certain privileges

if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root or sudo privileges" 
	exit 1
fi

NGX_CONFIG_FILE='/etc/nginx/nginx.conf'
NGX_ENABLED='/etc/nginx/sites-enabled'
NGX_AVAILABLE='/etc/nginx/sites-available'
WEBDIR='/var/www/deepweb'
TORRC='/etc/tor/torrc'
HOSTNAME=$(cat /var/lib/tor/hidden_service/hostname)
function banner()
    {
echo "     _____ _ _ _       _     _                   "
echo "    | ____| (_) |_ ___| |   (_)_ __  _   ___  __ "
echo "    |  _| | | | __/ _ \ |   | | '_ \| | | \ \/ / "
echo "    | |___| | | ||  __/ |___| | | | | |_| |>  <  "
echo "    |_____|_|_|\__\___|_____|_|_| |_|\__,_/_/\_\ "
echo
echo "	  | Follow and suscribe our Youtube channel |  "
echo "	  | https://www.youtube.com/channel/UCHERlfKz2HOnRMO3dZBGzPw | "
echo "	  | Email: Hackuin [at] Ymail [.] com | "

    }


function required() {
	apt install -y nginx
	apt install -y tor
}


function tor() {

	echo 'HiddenServiceDir /var/lib/tor/hidden_service/' >> $TORRC
	echo 'HiddenServicePort 80 127.0.0.1:80' >> $TORRC
	service tor restart
	echo 
	echo 'Your .onion linke is: ' $HOSTNAME
	echo
}

function nginxconfig(){
	# sed -i '/# server_name_in_redirect/c\        server_name_in_redirect off;' $NGX_CONFIG_FILE
	# sed -i '/# port_in_redirect/c\        port_in_redirect off;' $NGX_CONFIG_FILE
	mv $NGX_CONFIG_FILE $NGX_CONFIG_FILE.bak
	cp nginx.conf /etc/nginx/
	echo " server { listen 127.0.0.1:80; root $WEBDIR; index index.html; server_name $HOSTNAME; } " > $NGX_AVAILABLE/deepweb
	rm /etc/nginx/sites-enabled/default 2>/dev/null
	rm /etc/nginx/sites-available/default 2>/dev/null
	ln -s $NGX_AVAILABLE/deepweb $NGX_ENABLED/ 2>/dev/null
	systemctl restart nginx
}

function main() { 
		banner 
		required 
		tor
		ufw allow 'nginx HTTP'
		mkdir $WEBDIR 2>/dev/null
		echo " <html><body><h1>Edit your html file at $WEBDIR/ </h1></body></html>" > $WEBDIR/index.html
		chmod 755 $WEBDIR
		nginxconfig
		echo 'Open your torbrowser and access the link ' $HOSTNAME
}


main
