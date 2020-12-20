#!/bin/bash

while true; do
    clear

    echo "Bienvenue sur le script d'installation de votre nouveau serveur FiveM !"
    echo -e "\nAvant toutes choses, veuillez vous rendre sur [https://keymaster.fivem.net/] pour enregistrer votre clé de licence fivem"
    read -p "
Veuillez renseigner votre clé de licence : " licenseKey

    fivemKeyExample="r4xry6cjziog42fqjtq97k18jiklzona"
    steamApiKeyExample="9G23D81888D5986G5E6E9EFA54339726"

    if [[ ${#licenseKey} == ${#fivemKeyExample} ]]; then
        sleep 0.5
        licenseKey=$licenseKey
        break
    else
        echo "Clé de licence invalide !"
        sleep 0.5
    fi
done

clear

# Selection du dossier d'installation

read -p "Où souhaitez vous installer votre serveur ? [defaut: fivemserver] " installDirectory

mkdir $installDirectory
cd $installDirectory
clear

# Telechargement des fichiers du serveur

while true; do

    echo "Téléchargement des fichiers du serveur en cours.."

    sleep 0.5

    wget https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/3184-6123f9196eb8cd2a987a1dd7ff7b36907a787962/fx.tar.xz

    tar xf fx.tar.xz
    rm fx.tar.xz
    git clone https://github.com/citizenfx/cfx-server-data.git

    mv ./cfx-server-data/resources ./
    sudo rm -R ./cfx-server-data

    sleep 0.5
    echo ""

    if [[ -e resources ]]; then
        echo "Les fichiers ont bien téléchargé avec succès !"
        break
    else
        echo "Une erreur s'est produite lors du téléchargement des fichiers."

        read -p "
Voulez vous réessayer ? [o/N] " retryDownload

        echo ""

        case $retryDownload in
        [yY][eE][sS] | [yY] | [oO][uU][iI] | [oO])
            clear
            ;;
        *)
            clear
            echo "Installation du serveur annulée.."
            sleep 1
            clear
            exit
            ;;
        esac

    fi

done

clear

# Création de la configuration du serveur

echo -e "Configuration du serveur : "
sleep 1.5
echo ""
clear

read -p "Entrez le nom de votre serveur : [defaut: FXServer] " serverName

if [[ ! $serverName ]]; then
    serverName="FXServer"
else
    serverName="${serverName}"
fi

# Selection du port du serveur
while true; do

    read -p "Quel port voulez vous attribuer à votre serveur ? [defaut: 30120] : " serverPortDefine

    len=${#serverPortDefine}
    numbervar=$(echo "$serverPortDefine" | tr -dc '[:digit:]')
    if [[ $len -ne ${#numbervar} ]]; then
        clear
        echo ""
        echo "$serverPortDefine n'est pas un nombre"
    elif [[ ! $serverPortDefine ]]; then
        serverPort=30120
        clear
        break
    else
        serverPort=$serverPortDefine
        clear
        break
    fi

done

while true; do
    clear
    read -p "Entrez votre steamApiKey [https://steamcommunity.com/dev/apikey] : " steamApiKey

    if [[ ${#steamApiKey} == ${#steamApiKeyExample} ]]; then
        sleep 0.5
        steamApiKey=$steamApiKey
        break
    else
        clear
        echo "Steam API Key invalide !"
        sleep 0.5
    fi

done

echo "Génération de la configuration en cours avec les informations suivantes : "
echo ""
echo "Nom du serveur : ${serverName}"
echo "Port selectionné : ${serverPort}"
echo "SteamAPIKey : ${steamApiKey}"
echo ""
sleep 3

# Création du script de démarrage

echo "./run.sh +exec server.cfg" >start.sh
chmod +x start.sh

echo -e "# Configuration du serveur fivem | AwiZy63#5587
    # Only change the IP if you're using a server with multiple network interfaces, otherwise change the port only.
    endpoint_add_tcp \"0.0.0.0:${serverPort}\"
    endpoint_add_udp \"0.0.0.0:${serverPort}\"

    # These resources will start by default.
    ensure mapmanager
    ensure chat
    ensure spawnmanager
    ensure sessionmanager
    ensure basic-gamemode
    ensure hardcap
    ensure rconlog

    # This allows players to use scripthook-based plugins such as the legacy Lambda Menu.
    # Set this to 1 to allow scripthook. Do note that this does _not_ guarantee players won't be able to use external plugins.
    sv_scriptHookAllowed 0

    # Uncomment this and set a password to enable RCON. Make sure to change the password - it should look like rcon_password \"YOURPASSWORD\"
    #rcon_password \"\"

    # A comma-separated list of tags for your server.
    # For example:
    # - sets tags \"drifting, cars, racing\"
    # Or:
    # - sets tags \"roleplay, military, tanks\"
    sets tags \"default\"

    # A valid locale identifier for your server's primary language.
    # For example \"en-US\", \"fr-CA\", \"nl-NL\", \"de-DE\", \"en-GB\", \"pt-BR\"
    sets locale \"root-AQ\" 
    # please DO replace root-AQ on the line ABOVE with a real language! :)

    # Set an optional server info and connecting banner image url.
    # Size doesn't matter, any banner sized image will be fine.
    #sets banner_detail \"https://url.to/image.png\"
    #sets banner_connecting \"https://url.to/image.png\"

    # Set your server's hostname
    sv_hostname \"${serverName}\"

    # Nested configs!
    #exec server_internal.cfg

    # Loading a server icon (96x96 PNG file)
    #load_server_icon myLogo.png

    # Remove the \`#\` from the below line if you do not want your server to be listed in the server browser.
    # Do not edit it if you *do* want your server listed.
    #sv_master1 \"\"

    # Add system admins
    add_ace group.admin command allow # allow all commands
    add_ace group.admin command.quit deny # but don't allow quit
    add_principal identifier.fivem:1 group.admin # add the admin to the group

    # enable OneSync (required for server-side state awareness)
    set onesync on

    # Server player slot limit (see https://fivem.net/server-hosting for limits)
    sv_maxclients 48

    # Steam Web API key, if you want to use Steam authentication (https://steamcommunity.com/dev/apikey)
    # -> replace \"\" with the key
    set steam_webApiKey \"${steamApiKey}\"

    # License key for your server (https://keymaster.fivem.net)
    sv_licenseKey ${licenseKey}
    " >server.cfg

clear

sleep 0.5

echo "Configuration du serveur terminée !"

sleep 1


clear

# Installation terminée

echo "Installation de votre serveur terminée !"
echo "
Pour lancer votre serveur, faites : 

cd ./${installDirectory} && ./start.sh"
