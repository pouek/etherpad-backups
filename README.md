# etherpad-backups
Shell script to backup your favorite public pads, hosted on any [etherpad](https://etherpad.org/) instance, automagically !

# Features
- It can be used by anyone, i.e. without admin rights or any logins, to archive (regularly or not) your favorite pads.

- The file's name is made of the pad's name followed by the date. This allows you to keep track of the evolution of your pads.

- To preserve disk space, if nothing has changed, it will replace the downloaded pad by a link to the previous backup.

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
   - Server to download from
   - Pads names to download
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

_Example file to be at /etc/cron.weekly/pad (or "/etc/cron.monthly/pad" ...)__ 
```
#!/bin/bash
/bin/bash /home/path/to/incr_backup.sh automatic
```


# More details
The code is documented, [read it](https://github.com/pouek/etherpad-backups/blob/main/etherpad-backups.sh) ;)


# To-do
- ability to download from multiple {server+pads} groups
- add a way to delete useless symlinks
- add connection to server with login:password for private pads ?
