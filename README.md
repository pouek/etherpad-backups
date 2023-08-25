# etherpad-backups
Script to backup your favorite public pads, hosted on any etherpad instances, automagically !

# Features
- It can be used by anyone, i.e. without admin rights or any logins, to archive (regularly or not) your favorite pads.

- The file's name is made of the pad's name followed by the date. This allows you to keep track of the evolution of your pads.

- To preserve disk space, if nothing has changed, it will replace the downloaded pad by a link to the previous backup.

- Examples of etherpad servers, so you know where you can download with this tool from :
    • https://framapad.org and its subdomains [annuel](https://annuel.framapad.org), [mensuel](https://mensuel.framapad.org), ...
    • More instances [listed on chatons.org](https://www.chatons.org/search/by-service?service_type_target_id=All&field_alternatives_aux_services_target_id=All&field_software_target_id=224&field_is_shared_value=All&title=) 


# Usage
- Edit the script with all your settings
- To backup from different servers, create one more script for each one 
- Add the script(s) to your anacrontab to enable automatic backups of your etherpads
- Manually update your pads when you need

# More details
The code is documented, read it ;)


# To-do
- add a way to delete useless symlinks
- add connection to server with login:password ?
