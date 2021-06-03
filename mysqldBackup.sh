#!/usr/bin/env bash

u="\e[4m"
r=$(tput setaf 1)
g=$(tput setaf 2)
b=$(tput setaf 4)
n=$(tput sgr0)
nb=$(tput bold)
c=$(tput setaf 6)

#
if ! [ -f mybk.conf ]; then
    printf "${u}mybk.conf${n} "
    printf "[${r}ERROR${n}] mybk.conf no existe! \n"
    exit
fi

if ! [ -f mybkFunc.sh ]; then
    printf "${u}mybkFunc.sh${n} " 
    printf "[${r}ERROR${n}] mybkFunc.sh not existe! \n"
    exit
fi

source mybk.conf 
source mybkFunc.sh

if ! [ -d "$TMP_DIR" ]; then
    `mkdir -m 755 $TMP_DIR`
fi

logDate

clear
printf "${c}$version${n} \n"
printf "${nb}Una manera fácil de hacer respaldos de base de datos Mysql${n} \n\n"

START_NS=`date +%s%N`
START=`date +%s`

#
printf "Buscando servicio${n}"
if ! mysqlService; then
    printf "%10s\n" " [${r}FAIL${n}] Vea mybk.log para mas detalles."
    `echo "Mysql parece no estar donde especificaste, revisa #MYSQL SERVER LINUX en mybk.conf" >> mybk.log 2>&1`
    exit
fi
printf "%10s\n" " [${g}OK${n}]"


#
printf "Conectandose al sevidor en ${u}$MYSQL_HOST${n}"
if ! valConnectionData; then
    printf "%10s\n" " [${r}FAIL${n}] Ver mybk.log para mas detalles."
    `echo "Faltan datos de acceso, ponlos en #MYSQL DATA CONNECTION en mybk.conf y verifica .access.cnf" >> mybk.log 2>&1`
    exit
else
    if ! mysqlCreateCredentialsFile; then
	printf "%10s\n" " [${r}FAIL${n}] Vea mybk.log para mas detalles."
	`echo "Error al crear .access.cnf" >> mybk.log 2>&1`
	exit
    fi
    
    if ! testMysqlConnection; then
	printf "%10s\n" " [${r}FAIL${n}] Ver mybk.log para mas detalles."
	exit
    fi
    printf "%10s\n" " [${g}OK${n}]"
fi


#
printf "Haciendo respaldo de ${u}$DATABASE${n} "
if ! backupDatabase; then
    printf "%10s\n" "[${r}FAILED${n}] Ver mybk.log para mas detalles."
    exit
fi
printf "%10s\n" "[${g}OK${n}]"

if [ "$COMPRESS" = true ]; then
    printf "Comprimiendo ${u}$DATABASE${n} "
    if ! tarCompress; then
	printf "%10s\n" "[${r}FAILED${n}] Ver mybk.log para mas detalles."
	`echo "Error al comprimir el respaldo" >> mybk.log 2>&1`
    else
	printf "%10s\n" "[${g}OK${n}]"
    fi
fi


#
if [ "$SEND_TO_REMOTE" = true ]; then
    printf "Enviando a ${u}$REMOTE_HOST${n} "
    if ! sendToRemoteHost; then
	printf "%10s\n" "[${r}FAILED${n}] Error al enviar el respaldo!"
	exit
    else
	printf "%10s\n" "[${g}OK${n}]"
    fi
fi


#
if [ "$DEL_LOCAL_BK" = true ]; then
    printf "Borrando el respaldo local${n} "
    if [ "$SEND_TO_REMOTE" = true ]; then
	if ! delLocalBK; then
	    printf "%126s\n" "[${r}FAILED${n}] No puedo borra el respaldo!"
	else
	    printf "%94s\n" "[${g}OK${n}]"
	fi
    else
	printf "${u}$DATABASE-$TIMESTAMP${n}: No se ha eliminado por que es el único backup que existe."
    fi
fi


#printf "Sending email notification to ${u}$TO${n} "
#if ! sendEmail ; then
#    printf "%82s\n" "[${r}FAILED${n}] Can't send email!"
#fi

END_NS=`date +%s%N`
END=`date +%s`

let TIME_NS=$END_NS-$START_NS
let TOTAL_TIME=$END-$START

echo -ne "\nHe tardado: -$TOTAL_TIME- segundos. \n"
exit
