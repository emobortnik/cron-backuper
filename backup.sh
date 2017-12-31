#!/bin/bash

ip=$(wget -qO- eth0.me)


mysqldump=1  #####создавать дамп всех бд 1 — да; 0 — нет
filedump=1 #####создавать бекап всех файлов 1 — да; 0 — нет
upload=1 #### загружать на удалённый сервер? 1 — да; 0 — нет
user="root"
remotehost="" #куда загружать бекапы, работает только если upload = 1
dir="/backup/date +%d.%m.%Y/$ip" #директория куда загружать бэкапы


####создание дампа всех БД
USER="root"  #юзер
PASSWORD="superpassword" #пароль
OUTPUT="/backup/$ip"   #путь куда создаются дампы. 





#####################do not editcode bellow#####################

#check root permissions
if [ "x$(id -u)" != 'x0' ]; then
    echo 'Error: this script can be executed only by root'
    exit 1
fi






#check os
if [ -f /etc/redhat-release ]; then
  yum install rsync -y
fi

if [ -f /etc/lsb-release ]; then
  apt install rsync -y 
fi




echo -e "\n" » /var/log/$0.log
echo -e "\n" » /var/log/$0.log
echo -e "\n" » /var/log/$0.log

echo  » /var/log/$0.log
echo -e "\e[42m============================$(date +'%d-%b-%Y %R')=========================\e[0m"  » /var/log/$0.log
echo -e "\e[42m==================================START===============================\e[0m"  » /var/log/$0.log

sleep 3

# Create directory if not exist
if [[ ! -d $OUTPUT && ! -L $OUTPUT ]]; then
mkdir -p $OUTPUT && cd $OUTPUT
fi



if [ $mysqldump = "1" ]; then

databases=mysql --user=$USER --password=$PASSWORD -e "SHOW DATABASES;" | tr -d "| " | grep -v Database

for db in $databases; do
    if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != _* ]] ; then
       
       mysqldump —routines —skip-add-locks —user=$USER —password=$PASSWORD —databases $db  > $OUTPUT/$db.sql;
       echo -e "Dump \e[34m$db\e[0m was successfully created and located here: \033[1m\e[34m $OUTPUT/$db.sql\e[0m\033[0m"   » /var/log/$0.log
        

fi
      done
fi

sleep 4

#create filedump
if [ $filedump = "1" ]; then
echo -e "Creating \e[34mserver_backup.tar.gz\e[0m has started. Log of this operation is not included." » /var/log/$0.log
sleep 1
echo -e "\n"  » /var/log/$0.log
cd $OUTPUT && tar cvpzf server_backup.tar.gz —exclude=/ztmp —exclude=/proc —exclude=/ztemp —exclude=/media —exclude=/mnt —exclude=/opt —exclude=/srv —exclude=/tmp —exclude=$OUTPUT/server_backup*.tar.gz —exclude=/backup —one-file-system / 
echo -e "Dump \e[34mserver_backup.tar.gz\e[0m was successfully created and located here: \033[1m\e[34m $OUTPUT/$db.sql\e[0m\033[0m"  » /var/log/$0.log
else 
echo -e "\n"  » /var/log/$0.log
echo -e "Сreating \e[34mserver_backup.tar.gz\e[0m is not enabled"  » /var/log/$0.log
fi


sleep 3


# Create directory if not exist in remote host and upload backup
if [ $upload = "1" ]
then
ssh $user@$remotehost 'dir="'"$dir"'"; test -d "$dir" || mkdir -p "$dir"'
 rsync -avzh —progress —remove-source-files -W $OUTPUT/*.tar.gz $user@$remotehost:$dir 
 sleep 1
 echo -e "\n"  » /var/log/$0.log
 echo -e "\e[34mserver_backup.tar.gz\e[0m was successfully upload to your remote host."  » /var/log/$0.log
 sleep 2
 rsync -avzh —progress —remove-source-files -W $OUTPUT/*.sql $user@$remotehost:$dir
 echo -e "\e[34msql-files\e[0m was successfully upload to your remote host."  » /var/log/$0.log
else
echo -e "Uploading to remote is not enabled"  » /var/log/$0.log
fi

echo  » /var/log/$0.log
echo -e "\e[42m============================$(date +'%d-%b-%Y %R')=========================\e[0m"  » /var/log/$0.log
echo -e "\e[42m===================================END===============================\e[0m"  » /var/log/$0.log
