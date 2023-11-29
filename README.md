# etherpad-backups
Script Shell pour sauvegarder vos pads publics préférés, d'une ou plusieurs instances d'etherpad, automatiquement !

[English read-me below.](https://github.com/pouek/etherpad-backups/blob/main/README.md#english-read-me)

# Caractéristiques

Il peut être utilisé par n'importe qui, c'est-à-dire sans droits d'administration ou identifiants, pour archiver (régulièrement ou non) vos pads préférés.
Le nom du fichier sauvegardé est fait du nom du pad suivi de la date. Cela vous permet de suivre l'évolution de vos pads.
Pour préserver l'espace disque, il remplacera, quand ils sont les mêmes, le pad téléchargé par un lien vers le précédent.
Plusieurs pads de plusieurs serveurs dans un seul lancement de script.
Fichier _config.txt_ (optionnel) pour stocker vos paramètres et les rendre facilement accessibles et modifiables.
Exemples de serveurs etherpad, vous pouvez télécharger avec cet outil à partir de :
https://framapad.org et ses sous-domaines annuel, mensuel, ...
Plus d'instances listées sur chatons.org en cherchant par _services_ et en sélectionnant _text-processor_

# Installer

Cliquer ici pour télécharger zip.
L'extraire, le lancer, profiter !

# Utilisation

Modifier le script avec tous vos paramètres :
_filetype_ à télécharger : "odt" ou "pdf"
_Nom d'utilisateur_, obligatoire si script a commencé par cron/anacron
_Dossier de téléchargement_
_Les serveurs_ à télécharger, et pour chaque serveur...
Les _noms de Pads_ pour le télécharger depuis
Lancer le script avec
```
chmod u+x etherpad-backups.sh
```
Mettre à jour manuellement les pads, donc ponctuellement.
Note : le paramètre _manuel_ peut être modifié au choix, c'est une option pour aider à suivre les effectuées.
```
./etherpad-backups.sh manuel
```
ou
```
/chemin/complet/vers/etherpad-backups.sh manuel
```
Ajouter les scripts à _cron_ pour activer les sauvegardes automatiques définies dans le script ou le fichier _config.txt_ .

Installer _Anacrontab_ dans votre système, pour qu'il sauvegarde aussi le jour suivant où s'allumera le pc, s'il ne l'était pas le jour où _cron_ était supposé faire la sauvegarde.

Exemple de fichier à placer à /etc/cron.weekly/pad ou /etc/cron.monthly/pad.

Code minimal :
```
#!/bin/bash
/bin/bash /home/path/to/etherpad-backups.sh automatique
```
Plus de détails

Le code est documenté, [lis le](https://github.com/pouek/etherpad-backups/blob/main/etherpad-backups.sh) ;)


# À faire
- ajouter la connexion au serveur avec utilisateur:motdepasse pour les pads privés ?


# English read-me
Shell script to backup your favorite public pads, from [etherpad](https://etherpad.org/) instances, automagically !

# Features
- It can be used by anyone, i.e. without admin rights or any logins, to archive (regularly or not) your favorite pads.
- The file's name is made of the pad's name followed by the date. This allows you to keep track of the evolution of your pads.
- To preserve disk space, it will replace the downloaded pad by a link to the previous one, when they are the same.
- Multiple pads from multiple servers in one script launch.
- Optionnal config.txt file to store your parameters and make it easily accessible and editable.
- Examples of etherpad servers, so you know where you can download with this tool from :
    - https://framapad.org and its subdomains [annuel](https://annuel.framapad.org), [mensuel](https://mensuel.framapad.org), ...
    - More instances [listed on chatons.org](https://www.chatons.org/search/by-service?service_type_target_id=All&field_alternatives_aux_services_target_id=All&field_software_target_id=224&field_is_shared_value=All&title=) 

# Install
- [Click here to download zip](https://github.com/pouek/etherpad-backups/archive/refs/heads/main.zip).
- Extract, launch, enjoy
  
# Usage
- Edit the script with all your settings :
   - Filetype to download : "odt" or "pdf"
   - Username, mandatory if script started by cron/anacron
   - Download folder path
   - Servers to download from, and for each server...
   - Pads names to download it from
- Make the script executable with
  ```
  chmod u+x etherpad-backups.sh
  ```
- To backup from different servers, create one more script for each one 
- Manually update your pads when you need with :
_Note : the manual parameter can be what you want, it is an option to help track which backups were made and when_
```
./etherpad-backups.sh manual
```
or
```
/full/path/to/etherpad-backups.sh manual
```

## Add the script(s) to your cron to enable automatic backups of your etherpads
__Install Anacrontab to your system, so it also backup the next day you power on your pc, in case you didn't the day cron was supposed to do the backup.__

[Example file](https://github.com/pouek/etherpad-backups/blob/main/pad) to be placed at ``` /etc/cron.weekly/pad ``` or ``` /etc/cron.monthly/pad ```. 

Minimal code :
```
#!/bin/bash
/bin/bash /home/path/to/etherpad-backups.sh automatic
```


# More details
The code is documented, [read it](https://github.com/pouek/etherpad-backups/blob/main/etherpad-backups.sh) ;)


# To-do
- add connection to server with login:password for private pads ?
