# ✔️ Respados de base de datos Mysql - Script en bash

<p align="center">
  <a href="https://github.com/rasalopa/mysql-db-bk/archive/refs/heads/master.zip" target="_blank">
    <img src="https://img.shields.io/github/downloads/rasalopa/mysql-db-bk/total.svg" alt="Total Downloads">
  </a>
  <a href="https://github.com/rasalopa/mysql-db-bk/" target="_blank">
    <img src="https://svgshare.com/i/Zhy.svg" alt="OS">
  </a>
  <a href="https://www.gnu.org/software/bash/" target="_blank">
    <img src="https://img.shields.io/badge/Made%20with-Bash-1f425f.svg" alt="Bash">
  </a>
  <a href="https://github.com/rasalopa/mysql-db-bk/releases" target="_blank">
    <img src="https://img.shields.io/github/release/rasalopa/mysql-db-bk.svg" alt="Release">
  </a>
</p>

> Este pequeño script escrito en Bash te permite hacer respaldos de tus bases de datos de Mysql, solo tienes que decirle al script donde se encuentra tu servidor y poner los datos de acceso.
> 
> También puede comprimir dichos respaldos a .tar y se pueden enviar a un servidor remoto.
> 

### ️⚙️ Cómo usar
1️⃣ Clona este repositorio y dá permisos al directorio
```
git clone https://github.com/rasalopa/mysql-db-bk.git
```
```
chmod 755 mysql-db-backup/mysqldBackup.sh
```
2️⃣ Escribe en el archivo mybk.conf la información de tu servidor
```
mv mybk.conf.example mybk.conf 
```
```
MYSQL=/usr/bin/mysql
MYSQLDUMP=/usr/bin/mysqldump
MYSQL_SOCK=/var/lib/mysql/mysql.sock
```
3️⃣ Ahora los datos de acceso
```
DATABASE=database_to_backup
MYSQL_USER=mysql_user
MYSQL_PASSWD='mysql_passwd'
MYSQL_HOST=localhost
```
4️⃣ Ejecuta el script
```
./mysqldBackup.sh
```

---

> 💡 Probado en CentOS 7 y Debian 10 con Mysql  5.7 y MariaDB 10.3
