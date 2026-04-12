pgbackrest
==========
	It supports Full backups, Incremental backups and Differential backups.
	We need to configure the SSH passwordless authentication between source and backup servers.
	PostgreSQL version is different and pg_backrest version is different.
	Backup will be taken, encrypted and compressed by default.
	We can maintain backups in multiple repositories / backup servers.
	We can restore specific database from the backup.
	We can restore the delta changes. (only the changes after the full backup restoration).
	Pgbackrest will delete the expired backups as per the full backups retention.
 

Step 1  Prepare the Source and Backup Servers.
Step 2  We need to install pgbackrest on both servers.
Step 3  We need to configure pgbackrest on both servers.
Step 4  We need to configure SSH passwordless authentication between source and backup servers
Step 5  We need to change the permissions for /etc/pgbackrest.conf file and /var/log/pgbackrest directory.
Step 6  We need to build the source database server and enable the archive and archive command.
Step 7  We need to add repo and database server parameters in pgbackrest.conf
Step 8  We need to create a stanza in backup server.
Step 9  We need to add the backup server ip entry in pg_hba.conf in source server.
Step 10  Perform full, incr and diff backup on the backup server.

Source Server:-
[root@localhost ~]# yum install pgbackrest

Backup Server:-
[root@localhost ~]# yum install pgbackrest
 
Source Server:-
[root@localhost ~]# cat /etc/pgbackrest.conf  check the file is created or not.
[dba@localhost log]$ pg_ctl -D /dba_instance/data2/ start
[root@localhost ~]# chown postgres:postgres /etc/pgbackrest.conf  update permissions
[dba@localhost ~]$ ifconfig
[dba@localhost ~]$ cat /dba_instance/data2/postmaster.pid 
[dba@localhost ~]$ vi /etc/pgbackrest.conf 
[global]
repo1-host=<Backup server ip address>  backup server ip address
repo1-host-user=dba  Backup server user name.
process-max=2
log-level-console=info
log-level-file=debug
repo1-path=/dba_instance/dbrepo
repo1-retention-full=2
start-fast=y
stop-auto=y

[data2_backup]  Stanza name to identify the database backup
pg1-path=/dba_instance/data2  Data directory path
#pg1-host=<source server ip address>
#pg1-host-user=postgres
#pg1-pg-user=postgres
#pg1-port=5432

[root@localhost ~]#

Backup Server:-
[root@localhost ~]# chown postgres:postgres /etc/pgbackrest.conf
[root@localhost ~]# mkdir /dba_instance/dbrepo
[root@localhost ~]# vi /etc/pgbackrest.conf 
[global]
#repo1-host=192.168.112.220
#repo1-host-user=dba
process-max=2
log-level-console=info
log-level-file=debug
repo1-path=/dba_instance/dbrepo
repo1-retention-full=2
start-fast=y
stop-auto=y

[data2_backup]  Stanza name to identify the database backup
pg1-path=/dba_instance/data2  Data directory path
pg1-host=<source server ip address>
pg1-host-user=postgres
#pg1-pg-user=postgres
pg1-port=5432

[root@localhost ~]# cat /etc/pgbackrest.conf 
[root@localhost ~]# ifconfig

Source Server:-
[dba@localhost ~]$ ssh-keygen -t rsa
[dba@localhost ~]$ ssh-copy-id <backup server username>@<backup server ip address>
[dba@localhost ~]$ ssh <backup server username>@<backup server ip address> "chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys"
[dba@localhost ~]$ ssh <backup server username>@<backup server ip address>
Activate the web console with: systemctl enable --now cockpit.socket
Last login: Thu Apr 24 20:38:24 2025 from 192.168.112.215
[dba@localhost ~]$ exit
logout
Connection to 192.168.112.220 closed.

Backup Server:-
[root@localhost ~]# su - dba
[dba@localhost ~]$ ssh-keygen -t rsa
[dba@localhost ~]$ ssh-copy-id <source server username>@<source server ip address>
[dba@localhost ~]$ ssh <source server username>@<source server ip address> "chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys"
[dba@localhost ~]$ ssh <source server username>@<source server ip address>
Activate the web console with: systemctl enable --now cockpit.socket
Last login: Tue Apr 29 07:30:39 2025
[dba@localhost ~]$ exit
logout
Connection to 192.168.112.216 closed.

Source Server:-
[dba@localhost data2]$ vi postgresql.conf 
Archive_mode = on
Archive_command = ‘pgbackrest --stanza=data2_backup archive-push %p’
[dba@localhost data2]$ pg_ctl -D /dba_instance/data2/ restart
[dba@localhost data2]$ psql -p 5433 -U dba postgres
postgres=# show archive_command;
                 archive_command                  
--------------------------------------------------
 pgbackrest --stanza=data2_backup archive-push %p
(1 row)
postgres=# \q

Backup Server:-
[root@localhost ~]# chown postgres:postgres /dba_instance/dbrepo/ -R
[root@localhost ~]# chown postgres:postgres /var/log/pgbackrest/
[root@localhost ~]# su - postgres
[dba@localhost ~]$ cd /dba_instance/dbrepo/
[dba@localhost ~]$ pgbackrest --stanza=data2_backup stanza-create
2025-04-29 07:53:26.667 P00   WARN: unable to open log file '/var/log/pgbackrest/data2_backup-stanza-create.log': Permission denied
                                    NOTE: process will continue without log file.
2025-04-29 07:53:26.688 P00   INFO: stanza-create command begin 2.55.0: --exec-id=6615-71f9d932 --log-level-console=info --log-level-file=off --pg1-host=192.168.112.216 --pg1-host-user=dba --pg1-path=/dba_instance/data2 --pg1-port=5433 --repo1-path=/dba_instance/dbrepo --stanza=data2_backup
2025-04-29 07:53:27.732 P00   INFO: stanza-create for stanza 'data2_backup' on repo1
2025-04-29 07:53:27.851 P00   INFO: stanza-create command end: completed successfully (1241ms)
[dba@localhost ~]$ cd /dba_instance/dbrepo/
[dba@localhost dbrepo]$ pwd
/dba_instance/dbrepo
[dba@localhost dbrepo]$ ls -lrth
total 0
drwxr-x---. 3 dba dba 26 Apr 29 07:53 archive
drwxr-x---. 3 dba dba 26 Apr 29 07:53 backup
[dba@localhost dbrepo]$ cd archive/
[dba@localhost archive]$ ls -lrth
total 0
drwxr-x---. 2 dba dba 51 Apr 29 07:53 data2_backup
[dba@localhost archive]$ cd ..
[dba@localhost dbrepo]$ cd backup/
[dba@localhost backup]$ ls -lrth
total 0
drwxr-x---. 2 dba dba 49 Apr 29 07:53 data2_backup
[dba@localhost backup]$

Source Server:-
[dba@localhost data2]$ vi pg_hba.conf 
IPV4   Host	all	postgres	<backup server ip address>/32		trust
Replication   Host	replication	postgres	<backup server ip address>/32		trust
[dba@localhost data2]$ pg_ctl -D /dba_instance/data2/ reload
server signaled
[dba@localhost data2]$ 

Backup Server:-
[dba@localhost backup]$ pgbackrest --stanza=data2_backup backup --type=full

[dba@localhost backup]$ pgbackrest --stanza=postgresdb_backup --log-level-console=detail backup --type=full

[dba@localhost 16396]$ pgbackrest info --stanza=data2_backup
stanza: data2_backup
    status: ok
    cipher: none

    db (current)
        wal archive min/max (17): 000000010000000200000013/000000010000000200000015

        full backup: 20250429-080210F
            timestamp start/stop: 2025-04-29 08:02:10+05:30 / 2025-04-29 08:02:58+05:30
            wal start/stop: 000000010000000200000013 / 000000010000000200000013
            database size: 468.0MB, database backup size: 468.0MB
            repo1: backup set size: 47MB, backup size: 47MB

        full backup: 20250429-080627F
            timestamp start/stop: 2025-04-29 08:06:27+05:30 / 2025-04-29 08:06:58+05:30
            wal start/stop: 000000010000000200000015 / 000000010000000200000015
            database size: 468.0MB, database backup size: 468.0MB
            repo1: backup set size: 47MB, backup size: 47MB
[dba@localhost 16396]$

Source Server:-
[dba@localhost data2]$ psql -p 5433 -U dba postgres
postgres=# \db
postgres=# \l
postgres=# \du
postgres=# \c db1
You are now connected to database "db1" as user "dba".
db1=# \dt
db1=# create table incr(id integer,name varchar(20));
CREATE TABLE
db1=# insert into incr values(generate_series(1,100000),'manu');
INSERT 0 100000

Backup Server:-
[dba@localhost 16396]$ pgbackrest --stanza=data2_backup backup --type=incr
[dba@localhost 16396]$ pgbackrest info --stanza=data2_backup
[dba@localhost 16396]$ cd /dba_instance/dbrepo/backup/
[dba@localhost backup]$ ls -lrth
total 0
drwxr-x---. 6 dba dba 174 Apr 29 08:12 data2_backup
[dba@localhost backup]$ cd data2_backup/
[dba@localhost data2_backup]$ ls -lrth
total 8.0K
drwxr-x---. 3 dba dba   72 Apr 29 08:03 20250429-080210F
drwxr-x---. 3 dba dba   18 Apr 29 08:03 backup.history
drwxr-x---. 3 dba dba   72 Apr 29 08:07 20250429-080627F
drwxr-x---. 3 dba dba   72 Apr 29 08:12 20250429-080627F_20250429-081233I
lrwxrwxrwx. 1 dba dba   33 Apr 29 08:12 latest -> 20250429-080627F_20250429-081233I
-rw-r-----. 1 dba dba 2.5K Apr 29 08:12 backup.info
-rw-r-----. 1 dba dba 2.5K Apr 29 08:12 backup.info.copy
[dba@localhost data2_backup]$ cd 20250429-080627F_20250429-081233I
[dba@localhost 20250429-080627F_20250429-081233I]$ ls -lrth
total 760K
drwxr-x---. 7 dba dba   95 Apr 29 08:12 pg_data
-rw-r-----. 1 dba dba 379K Apr 29 08:12 backup.manifest.copy
-rw-r-----. 1 dba dba 379K Apr 29 08:12 backup.manifest
[dba@localhost 20250429-080627F_20250429-081233I]$ cd pg_data/
[dba@localhost pg_data]$ ls -lrth
[dba@localhost pg_data]$ cd base/
[dba@localhost base]$ ls -lrth
total 4.0K
drwxr-x---. 2 dba dba 4.0K Apr 29 08:12 16396
[dba@localhost base]$ cd 16396/
[dba@localhost 16396]$ ls -lrth

[dba@localhost 16396]$ pgbackrest --help
pgBackRest 2.55.0 - General help

Usage:
    pgbackrest [options] [command]

Commands:
    annotate        add or modify backup annotation
    archive-get     get a WAL segment from the archive
    archive-push    push a WAL segment to the archive
    backup          backup a database cluster
    check           check the configuration
    expire          expire backups that exceed retention
    help            get help
    info            retrieve information about backups
    repo-get        get a file from a repository
    repo-ls         list files in a repository
    restore         restore a database cluster
    server          pgBackRest server
    server-ping     ping pgBackRest server
    stanza-create   create the required stanza data
    stanza-delete   delete a stanza
    stanza-upgrade  upgrade a stanza
    start           allow pgBackRest processes to run
    stop            stop pgBackRest processes from running
    verify          verify contents of a repository
    version         get version

Use 'pgbackrest help [command]' for more information.

[dba@localhost 16396]$ pgbackrest --stanza=data2_backup backup --type=diff

[dba@localhost 16396]$ cd /dba_instance/dbrepo/backup/data2_backup/
[dba@localhost data2_backup]$ ls -lrth
total 8.0K
drwxr-x---. 3 dba dba   72 Apr 29 08:03 20250429-080210F
drwxr-x---. 3 dba dba   18 Apr 29 08:03 backup.history
drwxr-x---. 3 dba dba   72 Apr 29 08:07 20250429-080627F
drwxr-x---. 3 dba dba   72 Apr 29 08:12 20250429-080627F_20250429-081233I
drwxr-x---. 3 dba dba   72 Apr 29 08:20 20250429-080627F_20250429-081959D
lrwxrwxrwx. 1 dba dba   33 Apr 29 08:20 latest -> 20250429-080627F_20250429-081959D
-rw-r-----. 1 dba dba 3.2K Apr 29 08:20 backup.info
-rw-r-----. 1 dba dba 3.2K Apr 29 08:20 backup.info.copy
[dba@localhost data2_backup]$ cd 20250429-080627F_20250429-081959D
[dba@localhost 20250429-080627F_20250429-081959D]$ ls -lrth
total 760K
drwxr-x---. 7 dba dba   95 Apr 29 08:20 pg_data
-rw-r-----. 1 dba dba 380K Apr 29 08:20 backup.manifest.copy
-rw-r-----. 1 dba dba 380K Apr 29 08:20 backup.manifest
[dba@localhost 20250429-080627F_20250429-081959D]$ cd pg_data/
[dba@localhost pg_data]$ ls -lrth
[dba@localhost pg_data]$ cd base/
[dba@localhost base]$ ls -lrth
total 4.0K
drwxr-x---. 2 dba dba 4.0K Apr 29 08:20 16396
[dba@localhost base]$ cd 16396/
[dba@localhost 16396]$ ls -lrth
[dba@localhost 16396]$ pgbackrest info --stanza=data2_backup
[dba@localhost 16396]$

Source Server:-
db1=# insert into incr values(generate_series(1,100000),'manu');
INSERT 0 100000

Backup Server:-
[dba@localhost 16396]$ pgbackrest --stanza=data2_backup backup --type=incr
[dba@localhost 16396]$ pgbackrest info --stanza=data2_backup
[dba@localhost 16396]$


Source Server:-
db1=# insert into incr values(generate_series(1,100000),'manu');
INSERT 0 100000

Backup Server:-
[dba@localhost 16396]$ pgbackrest --stanza=data2_backup backup --type=incr

[dba@localhost 16396]$ pgbackrest info --stanza=data2_backup

[dba@localhost 16396]$

Source Server:-
db1=# select * from pg_class where relname='incr';
check the oid of the table and cross verify the same in the backup server in the base directory.

Backup Server:-
[dba@localhost 16396]$ cd /dba_instance/dbrepo/backup/data2_backup/
[dba@localhost data2_backup]$ ls -lrth
total 16K
drwxr-x---. 3 dba dba   72 Apr 29 08:03 20250429-080210F
drwxr-x---. 3 dba dba   18 Apr 29 08:03 backup.history
drwxr-x---. 3 dba dba   72 Apr 29 08:07 20250429-080627F
drwxr-x---. 3 dba dba   72 Apr 29 08:12 20250429-080627F_20250429-081233I
drwxr-x---. 3 dba dba   72 Apr 29 08:20 20250429-080627F_20250429-081959D
drwxr-x---. 3 dba dba   72 Apr 29 08:22 20250429-080627F_20250429-082220I
drwxr-x---. 3 dba dba   72 Apr 29 08:23 20250429-080627F_20250429-082257I
lrwxrwxrwx. 1 dba dba   33 Apr 29 08:23 latest -> 20250429-080627F_20250429-082257I
-rw-r-----. 1 dba dba 4.8K Apr 29 08:23 backup.info
-rw-r-----. 1 dba dba 4.8K Apr 29 08:23 backup.info.copy
[dba@localhost data2_backup]$ cd 20250429-080627F_20250429-082257I
[dba@localhost 20250429-080627F_20250429-082257I]$ cd pg_data/
[dba@localhost pg_data]$ ls -lrth
total 4.0K
drwxr-x---. 2 dba dba  35 Apr 29 08:23 log
drwxr-x---. 2 dba dba  21 Apr 29 08:23 pg_xact
drwxr-x---. 2 dba dba  27 Apr 29 08:23 global
drwxr-x---. 3 dba dba  23 Apr 29 08:23 pg_wal
drwxr-x---. 3 dba dba  19 Apr 29 08:23 base
-rw-r-----. 1 dba dba 201 Apr 29 08:23 backup_label.gz
[dba@localhost pg_data]$ cd base/
[dba@localhost base]$ ls -lrth
total 0
drwxr-x---. 2 dba dba 22 Apr 29 08:23 16396
[dba@localhost base]$ cd 16396/
[dba@localhost 16396]$ ls -lrth
total 1.3M
-rw-r-----. 1 dba dba 1.3M Apr 29 08:23 16520.gz
[dba@localhost 16396]$ 

Restoration of entire cluster using pgbackrest

Backup Server:-
[dba@localhost 16396]$ pgbackrest info --stanza=data2_backup
[dba@localhost 16396]$ 

Source Server:-
[dba@localhost data2]$ 
[dba@localhost data2]$ mkdir /dba_instance/restore_db
[dba@localhost data2]$ pgbackrest --stanza=data2_backup --db-path=/dba_instance/restore_db --set=20250429-080627F_20250429-082257I restore
[root@localhost pgbackrest]# chown postgres:postgres /var/spool/pgbackrest/ -R
[root@localhost pgbackrest]# chown postgres:postgres /var/log/pgbackrest/ -R
[root@localhost pgbackrest]# su - postgres
[dba@localhost ~]$ pgbackrest --stanza=data2_backup --db-path=/dba_instance/restore_db --set=20250429-080627F_20250429-082257I restore
[dba@localhost ~]$ cd /var/spool/pgbackrest/
[dba@localhost pgbackrest]$ ls

====================================================================================
Backup Server:-
[dba@localhost ~]$ pgbackrest --stanza=data2_backup backup --type=full

Source Server:-
[dba@localhost pgbackrest]$ ls
[dba@localhost pgbackrest]$ psql -p 5433 -U dba postgres
postgres=# \c db1
You are now connected to database "db1" as user "dba".
db1=# select count(*) from incr;
 count  
--------
 300000
(1 row)
db1=# insert into incr values(generate_series(1,100000),'manu');
INSERT 0 100000
db1=# select count(*) from incr;
 count  
--------
 400000
(1 row)

Backup Server:-
[dba@localhost ~]$ pgbackrest --stanza=data2_backup backup --type=incr
[dba@localhost ~]$ pgbackrest info --stanza=data2_backup

Source Server:-
db1=# insert into incr values(generate_series(1,100000),'manu');
INSERT 0 100000
db1=# select count(*) from incr;
 count  
--------
 500000
(1 row)

Backup Server:-
[dba@localhost ~]$ pgbackrest --stanza=data2_backup backup --type=incr
[dba@localhost ~]$ pgbackrest info --stanza=data2_backup

Source Server:-
db1=# insert into incr values(generate_series(1,100000),'manu');
INSERT 0 100000
db1=# select count(*) from incr;
 count  
--------
 600000
(1 row)

db1=# insert into incr values(generate_series(1,100000),'sreeni');
INSERT 0 100000

Backup Server:-
[dba@localhost ~]$ pgbackrest --stanza=data2_backup backup --type=diff
[dba@localhost ~]$ pgbackrest info --stanza=data2_backup
Source Server:-
db1=# insert into incr values(generate_series(1,100000),'john');
INSERT 0 100000
db1=# \q

Backup Server:-
[dba@localhost ~]$ pgbackrest --stanza=data2_backup backup --type=incr
[dba@localhost ~]$ pgbackrest info --stanza=data2_backup
	Copy the file name

Source Server:-
[dba@localhost ~]$ cd /dba_instance/restore_db/
[dba@localhost restore_db]$ pgbackrest --stanza=data2_backup --db-path=/dba_instance/restore_db --set=20250430-072743F_20250430-073314I restore
[dba@localhost restore_db]$ ls -lrth
[dba@localhost restore_db]$ vi postgresql.conf 
Update the port number
[dba@localhost restore_db]$ pg_ctl -D /dba_instance/restore_db/ start
[dba@localhost restore_db]$ psql -p 5435 -U dba db1
db1=# select count(*) from incr;
db1=# select count(*) from incr where name='john';
db1=# select count(*) from incr where name='sreeni';
db1=# select count(*) from incr where name='manu';
db1=# \q
[dba@localhost restore_db]$ psql -p 5433 -U dba db1
db1=# select count(*) from incr where name='manu';
db1=# select count(*) from incr where name='sreeni';
db1=# select count(*) from incr where name='john';
db1=# \q
[dba@localhost restore_db]$ psql -p 5435 -U dba db1
db1=# select * from pg_control_checkpoint() ;  to see the timeline ID
db1=# \q

[dba@localhost restore_db]$ psql -p 5433 -U dba db1
db1=# insert into incr values(generate_series(1,100000),'ojas');
INSERT 0 100000
db1=# \q

[dba@localhost restore_db]$ pg_ctl -D /dba_instance/restore_db/ stop
waiting for server to shut down.......... done
server stopped
[dba@localhost restore_db]$ pgbackrest --stanza=data2_backup --db-path=/dba_instance/restore_db --delta restore
[dba@localhost restore_db]$ vi postgresql.conf 
Update the port number
[dba@localhost restore_db]$ pg_ctl -D /dba_instance/restore_db/ start
[dba@localhost restore_db]$ psql -p 5435 -U dba db1
psql (17.4)
Type "help" for help.

db1=# select count(*) from incr where name='ojas';
 count 
-------
     0
(1 row)

db1=# \q


Backup Server:-
[dba@localhost ~]$ pgbackrest --stanza=data2_backup backup --type=incr

Source Server:-
[dba@localhost restore_db]$ pg_ctl -D /dba_instance/restore_db/ stop
[dba@localhost restore_db]$ pgbackrest --stanza=data2_backup --db-path=/dba_instance/restore_db --delta restore
[dba@localhost restore_db]$ vi postgresql.conf 
Update the port number
[dba@localhost restore_db]$ pg_ctl -D /dba_instance/restore_db/ start
[dba@localhost restore_db]$ psql -p 5435 -U dba db1
db1=# select count(*) from incr where name='ojas';
 count  
--------
 100000
(1 row)

db1=# \l
db1=# \q

Delta restore in pgBackRest does not restore the entire cluster. 
It restores only the files that are missing or different by comparing checksums with the backup, 
making the restore process faster and more efficient.

Restore single database using pgbackrest:-
==========================================
Source Server:-
[dba@localhost restore_db]$ psql -p 5433 -U dba db1
psql (17.4)
Type "help" for help.

db1=# create table delta(id integer,name varchar(20));
CREATE TABLE
db1=# insert into delta values(generate_series(1,1000),'chanak');
INSERT 0 1000
db1=# \q
[dba@localhost restore_db]$ psql -p 5435 -U dba db1
psql (17.4)
Type "help" for help.

db1=# \l
db1=# \c db5
You are now connected to database "db5" as user "dba".
db5=# \c db1
You are now connected to database "db1" as user "dba".
db1=# create table before_change(id integer,name varchar(20));
CREATE TABLE
db1=# insert into before_change values(generate_series(1,1000),'chanak');
INSERT 0 1000
db1=# \dt
db1=# show port;
 port 
------
 5435
(1 row)

db1=# \q


Backup Server:-
[dba@localhost ~]$ pgbackrest --stanza=data2_backup backup --type=incr

Source Server:-
[dba@localhost restore_db]$ pg_ctl -D /dba_instance/restore_db/ stop
[dba@localhost restore_db]$ pgbackrest --stanza=data2_backup --db-path=/dba_instance/restore_db --delta --db-include=db1 --type=immediate --target-action=promote restore
[dba@localhost restore_db]$ vi postgresql.conf
Update the port number 
[dba@localhost restore_db]$ pg_ctl -D /dba_instance/restore_db/ start
waiting for server to start....2025-04-30 08:03:31.910 IST [11949] LOG:  redirecting log output to logging collector process
2025-04-30 08:03:31.910 IST [11949] HINT:  Future log output will appear in directory "log".
... done
server started
[dba@localhost restore_db]$ psql -p 5435 -U dba db1
db1=# \dt
db1=# \l
db1=# 
db1=# \q

PITR using pgbackrest:-

Source Server:-
[dba@localhost restore_db]$ psql -p 5433 -U dba db1
db1=# create table t_Test (slno integer, ts timestamp);
CREATE TABLE
db1=# insert into t_test values (generate_series(1,1000),now());
INSERT 0 1000
db1=# select pg_switch_wal();
 pg_switch_wal 
---------------
 2/58028388
(1 row)

Backup Server:-
[dba@localhost ~]$ pgbackrest --stanza=data2_backup backup --type=full

Source Server:-
db1=# select now();
               now                
----------------------------------
 2025-04-30 08:13:30.189771+05:30
(1 row)
db1=# delete from t_test;
DELETE 1000
db1=# select pg_switch_wal();
 pg_switch_wal 
---------------
 2/5E018940
(1 row)
db1=# \q
[dba@localhost restore_db]$ pg_ctl -D /dba_instance/restore_db/ stop
[dba@localhost restore_db]$ rm -rf *
[dba@localhost restore_db]$ pgbackrest --stanza=data2_backup --db-path=/dba_instance/restore_db --type=time --target="2025-04-30 08:13:30.189771+05:30" restore
[dba@localhost restore_db]$ vi postgresql.conf 
Update the port number
[dba@localhost restore_db]$ pg_ctl -D /dba_instance/restore_db/ start
[dba@localhost restore_db]$ psql -p 5435 -U dba db1
db1=# \dt
db1=# select count(*) from t_test;
 count 
-------
  1000
(1 row)
db1=# 

Verify PG_DATA directory: In PG_DATA directory you will notice a new file: recovery.signal and postgresql.auto.conf. 
recovery.signal which tells PostgreSQL to enter normal archive recovery. 
pgBackRest restore command will also add many recovery parameters in postgresql.auto.conf. 
Verify parameter recovery_target_time shows desire recovery time.

Start PostgreSQL Service: Once all the above steps are done.

Verify logfile: Verify logfile to see everything went fine after restore and recovery.

Verify Data: Verify that required data available after restore and recovery.

End the recovery: As suggested in the logfile execute pg_wal_replay_resume() to end recovery and open DB to established connections. You can use utility pg_isready to verify it.

postgres=# select  pg_wal_replay_resume();
 pg_wal_replay_resume
----------------------
 
(1 row)
 
postgres=#
 
-bash-4.2$ /usr/pgsql-13/bin/pg_isready
/var/run/postgresql:5432 - accepting connections
-bash-4.2$


Point in Time Recovery (PITR) using pgBackRest in PostgreSQL - DBsGuru

Physical Backup using pgBackRest in PostgreSQL - DBsGuru

Configure pgbackrest on Backup Host - Remote in PostgreSQL - DBsGuru

How to Setup SSH Passwordless Login in Linux






