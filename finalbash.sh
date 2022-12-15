# Joel Saavedra Páez
# alu0101437415@ull.edu.es
# ULL
# Grado en Ingeniería Informática
# Sistemas Operativos
# Errores: 
# - Linea 47 y 48: no me reconoce el caracter * 
# - No invierte el orden entre inv y sopen o sdevice
# - Solo permite un usuario con la opcion -u
#!/bin/bash

# CONSTANTES
TITLE="Información del sistema para $HOSTNAME"
DATE=$(date +"%x %r%z")
UPDATE="Actualizada el $DATE POR $USER"

# ESTILOS
TEXT_BOLD=$(tput bold)
TEXT_GREEN=$(tput setaf 2)
TEXT_RESET=$(tput sgr0)

# VARIABLES 
filesystem=$(mount | tr -s ' ' | cut -d ' ' -f5 | sort -u) # Tipos de sistemas de archivos ordenados alfabéticamente
filesystem_inv=$(mount | tr -s ' ' | cut -d ' ' -f5 | sort -r -u) # Tipos de sistemas de archivos ordenados alfabéticamente a la inversa
inversa= # Variable para mostrar la tabla a la inversa
device= # Variable para mostrar la tabla teniendo en cuenta unicamente los dispositivos representados como device files
usuario= # Variable para trabajar con usuarios en lsof
noheaders=
archivos_abiertos=
dispositivos_abiertos=


# FUNCIONES
# Función que nos muestra nuestra tabla
tabla() {
    if [ "$inversa" == 1 ]; then # Con el parámetro inverso activado
        for type_filesystem in $filesystem_inv; do # Recorremos los tipos de sistemas de archivos ordenados a la inversa
            columna=$(df -a -t$type_filesystem | tail -n +2 | sort -n -r -k3 | tr -s ' ' | cut -d ' ' -f1,3,6) # Almacena las columnas "dispositivo" "espacio ocupado" y "punto montaje"
            numero_dispositivos=$(echo "$columna" | wc -l) # Número de dispositivos de cada sistema de archivos
            columna_ocupacion=$(df -a -t$type_filesystem | tail -n +2 | tr -s ' ' | cut -d ' ' -f3) # Ocupacion de c/ dispositivo de c/ sistema de archivos
            ocupacion_total= # Suma de las ocupacion de c/ dispositivo de c/ sistema de archivos
            for ocupacion_cada_dispositivo in $columna_ocupacion; do # Recorremos la ocupacion de cada dispositivo
                let ocupacion_total+=$ocupacion_cada_dispositivo # Sumamos las ocupaciones
            done
            columna_dispositivo=$(echo -e $columna | tr -s ' ' | cut -d ' ' -f1) # Columna con los dispositivos de nuestra tabla
            for dispositivo in $columna_dispositivo; do # Recorremos la columna dispositivo
                menor=$(stat -c %T $dispositivo 2>/dev/null || echo "?") # Sacamos el numero menor y si nos da error mostramos un ?
                mayor=$(stat -c %t $dispositivo 2>/dev/null || echo "?") # Sacamos el numero mayor y si nos da error mostramos un ?
                if [ "$menor" != "?" ]; then # Si el numero menor no da error pasamos a convertirlo
                    menor=$(echo "obase=10; ibase=16; $menor;" | bc ) # Convertimos el numero menor a decimal
                elif [ "$mayor" != "?" ]; then # Si el numero mayor no da error pasamos a convertirlo
                    mayor=$(echo "obase=10; ibase=16; $mayor;" | bc ) # Convertimos el numero mayor a decimal
                fi
                if [ "$menor" != "?" ] && [ "$mayor" != "?" ]; then # Si tenemos numero mayor y menor 
                    abiertos=$(lsof $dispositivo | tail -n +2 | wc -l ) # Hacemos un lsof al dispositivo en cuestion y contamos las lineas
                    if [ "$usuario" == 1 ]; then
                        us=$(lsof -u $usuario_elegido $dispositivo | tail -n +2 | wc -l)
                    fi
                fi
            done
            if [ "$usuario" == 1 ]; then 
                tabla_final+="${type_filesystem} ${numero_dispositivos} ${ocupacion_total} ${mayor} ${menor} ${abiertos} ${us} ${columna}\n" # Juntamos nuestras variables
            elif [ "$device" == 1 ] && [ "$usuario" != 1 ]; then
                tabla_final+="${type_filesystem} ${numero_dispositivos} ${ocupacion_total} ${mayor} ${menor} ${abiertos} ${columna}\n" # Juntamos nuestras variables
            else
                tabla_final+="${type_filesystem} ${numero_dispositivos} ${ocupacion_total} ${mayor} ${menor} ${columna}\n" # Juntamos nuestras variables    
            fi  
        done
        # Mostrar, ordenamiento, cabecera
        if [ "$usuario" == 1 ]; then
            echo "${TEXT_BOLD}Tipo  Nº Ocupa    M  m  Open OpenU Disposit. UsoMayor PuntoDeMontaje ${TEXT_RESET}" # Encabezado
            echo -e $tabla_final | cut -d ' ' -f1,2,3,4,5,6,7,8,9,10 | grep -v "?" | column -t # Mostramos nuestra tabla solo consideranto los dispositivos con un numero mayor y menor
        elif [ "$device" == 1 ] && [ "$usuario" != 0 ]; then # Con el parámetro devicefiles activado
            echo "${TEXT_BOLD}Tipo  Nº Ocupa    M  m  Open Dispositivo UsoMayor PuntoDeMontaje ${TEXT_RESET}" # Encabezado
            echo -e $tabla_final | cut -d ' ' -f1,2,3,4,5,6,7,8,9 | grep -v "?" | column -t # Mostramos nuestra tabla solo consideranto los dispositivos con un numero mayor y menor
        else
            echo "${TEXT_BOLD}Tipo         Nº  Ocupacion  M  m   Dispositivo  UsoMayor   PuntoDeMontaje${TEXT_RESET}" # Encabezado
            echo -e $tabla_final | cut -d ' ' -f1,2,3,4,5,6,7,8 | column -t # Mostramos nuestra tabla completa
        fi
    else
        for type_filesystem in $filesystem; do # Recorremos los tipos de sistemas de archivos ordenados alfabeticamente
            columna=$(df -a -t$type_filesystem | tail -n +2 | sort -n -r -k3 | tr -s ' ' | cut -d ' ' -f1,3,6) # Almacena las columnas "dispositivo" "espacio ocupado" y "punto montaje"
            numero_dispositivos=$(echo "$columna" | wc -l) # Número de dispositivos de cada sistema de archivos
            columna_ocupacion=$(df -a -t$type_filesystem | tail -n +2 | tr -s ' ' | cut -d ' ' -f3) # Ocupacion de c/ dispositivo de c/ sistema de archivos
            ocupacion_total= # Suma de las ocupacion de c/ dispositivo de c/ sistema de archivos
            for ocupacion_cada_dispositivo in $columna_ocupacion; do # Recorremos la ocupacion de cada dispositivo
                let ocupacion_total+=$ocupacion_cada_dispositivo # Sumamos las ocupaciones
            done
            columna_dispositivo=$(echo -e $columna | tr -s ' ' | cut -d ' ' -f1) # Columna con los dispositivos de nuestra tabla
            for dispositivo in $columna_dispositivo; do # Recorremos la columna dispositivo
                menor=$(stat -c %T $dispositivo 2>/dev/null || echo "?") # Sacamos el numero menor y si nos da error mostramos un ?
                mayor=$(stat -c %t $dispositivo 2>/dev/null || echo "?") # Sacamos el numero mayor y si nos da error mostramos un ?
                if [ "$menor" != "?" ]; then # Si el numero menor no da error pasamos a convertirlo
                    menor=$(echo "obase=10; ibase=16; $menor;" | bc ) # Convertimos el numero menor a decimal
                elif [ "$mayor" != "?" ]; then # Si el numero mayor no da error pasamos a convertirlo
                    mayor=$(echo "obase=10; ibase=16; $mayor;" | bc ) # Convertimos el numero mayor a decimal
                fi
                if [ "$menor" != "?" ] && [ "$mayor" != "?" ]; then # Si tenemos numero mayor y menor 
                    abiertos=$(lsof $dispositivo | tail -n +2 | wc -l ) # Hacemos un lsof al dispositivo en cuestion y contamos las lineas
                    if [ "$usuario" == 1 ]; then
                        us=$(lsof -u $usuario_elegido $dispositivo | tail -n +2 | wc -l ) 
                    fi
                fi
            done
            if [ "$usuario" == 1 ]; then 
                tabla_final+="${type_filesystem} ${numero_dispositivos} ${ocupacion_total} ${mayor} ${menor} ${abiertos} ${us} ${columna}\n" # Juntamos nuestras variables
            elif [ "$device" == 1 ] && [ "$usuario" != 1 ]; then
                tabla_final+="${type_filesystem} ${numero_dispositivos} ${ocupacion_total} ${mayor} ${menor} ${abiertos} ${columna}\n" # Juntamos nuestras variables
            else
                tabla_final+="${type_filesystem} ${numero_dispositivos} ${ocupacion_total} ${mayor} ${menor} ${columna}\n" # Juntamos nuestras variables    
            fi    
        done
        # Mostrar, ordenamiento, cabecera
        if [ "$archivos_abiertos" == 1 ] && [ "$dispositivos_abiertos" == 1 ]; then 
            error_comandos
        fi
        if [ "$noheaders" == 1 ]; then
            if [ "$usuario" == 1 ]; then
                if [ "$dispositivos_abiertos" == 1 ]; then
                    echo -e $tabla_final | cut -d ' ' -f1,2,3,4,5,6,7,8,9,10 | grep -v "?" | sort -n -r -k2 | column -t # Mostramos nuestra tabla solo consideranto los dispositivos con un numero mayor y menor
                elif [ "$archivos_abiertos" == 1 ]; then
                    echo -e $tabla_final | cut -d ' ' -f1,2,3,4,5,6,7,8,9,10 | grep -v "?" | sort -n -r -k6 | column -t # Mostramos nuestra tabla solo consideranto los dispositivos con un numero mayor y menor
                else
                    echo -e $tabla_final | cut -d ' ' -f1,2,3,4,5,6,7,8,9,10 | grep -v "?" | column -t # Mostramos nuestra tabla solo consideranto los dispositivos con un numero mayor y menor
                fi
            elif [ "$device" == 1 ] && [ "$usuario" != 1 ]; then # Con el parámetro devicefiles activado
                if [ "$dispositivos_abiertos" == 1 ]; then
                    echo -e $tabla_final | cut -d ' ' -f1,2,3,4,5,6,7,8,9 | grep -v "?" | sort -n -r -k2 | column -t # Mostramos nuestra tabla solo consideranto los dispositivos con un numero mayor y menor
                elif [ "$archivos_abiertos" == 1 ]; then
                    echo -e $tabla_final | cut -d ' ' -f1,2,3,4,5,6,7,8,9 | grep -v "?" | sort -n -r -k6 | column -t # Mostramos nuestra tabla solo consideranto los dispositivos con un numero mayor y menor
                else
                    echo -e $tabla_final | cut -d ' ' -f1,2,3,4,5,6,7,8,9 | grep -v "?" | column -t # Mostramos nuestra tabla solo consideranto los dispositivos con un numero mayor y menor
                fi
            else
                if [ "$dispositivos_abiertos" == 1 ]; then
                    echo -e $tabla_final | cut -d ' ' -f1,2,3,4,5,6,7,8 | sort -n -r -k2 | column -t # Mostramos nuestra tabla solo consideranto los dispositivos con un numero mayor y menor
                elif [ "$archivos_abiertos" == 1 ]; then
                    echo -e $tabla_final | cut -d ' ' -f1,2,3,4,5,6,7,8 | sort -n -r -k6 | column -t # Mostramos nuestra tabla solo consideranto los dispositivos con un numero mayor y menor
                else
                    echo -e $tabla_final | cut -d ' ' -f1,2,3,4,5,6,7,8 | column -t # Mostramos nuestra tabla solo consideranto los dispositivos con un numero mayor y menor
                fi
            fi
        else
            if [ "$usuario" == 1 ]; then
                if [ "$dispositivos_abiertos" == 1 ]; then
                    echo "${TEXT_BOLD}Tipo  Nº Ocupa    M  m  Open OpenU Disposit. UsoMayor PuntoDeMontaje ${TEXT_RESET}" # Encabezado
                    echo -e $tabla_final | cut -d ' ' -f1,2,3,4,5,6,7,8,9,10 | grep -v "?" | sort -n -r -k2 | column -t # Mostramos nuestra tabla solo consideranto los dispositivos con un numero mayor y menor
                elif [ "$archivos_abiertos" == 1 ]; then
                    echo "${TEXT_BOLD}Tipo  Nº Ocupa    M  m  Open OpenU Disposit. UsoMayor PuntoDeMontaje ${TEXT_RESET}" # Encabezado
                    echo -e $tabla_final | cut -d ' ' -f1,2,3,4,5,6,7,8,9,10 | grep -v "?" | sort -n -r -k6 | column -t # Mostramos nuestra tabla solo consideranto los dispositivos con un numero mayor y menor
                else
                    echo "${TEXT_BOLD}Tipo  Nº Ocupa    M  m  Open OpenU Disposit. UsoMayor PuntoDeMontaje ${TEXT_RESET}" # Encabezado
                    echo -e $tabla_final | cut -d ' ' -f1,2,3,4,5,6,7,8,9,10 | grep -v "?" | column -t # Mostramos nuestra tabla solo consideranto los dispositivos con un numero mayor y menor
                fi
            elif [ "$device" == 1 ] && [ "$usuario" != 1 ]; then # Con el parámetro devicefiles activado
                if [ "$dispositivos_abiertos" == 1 ]; then
                    echo "${TEXT_BOLD}Tipo  Nº Ocupa    M  m  Open Dispositivo UsoMayor PuntoDeMontaje ${TEXT_RESET}" # Encabezado
                    echo -e $tabla_final | cut -d ' ' -f1,2,3,4,5,6,7,8,9 | grep -v "?" | sort -n -r -k2 | column -t # Mostramos nuestra tabla solo consideranto los dispositivos con un numero mayor y menor
                elif [ "$archivos_abiertos" == 1 ]; then
                    echo "${TEXT_BOLD}Tipo  Nº Ocupa    M  m  Open Dispositivo UsoMayor PuntoDeMontaje ${TEXT_RESET}" # Encabezado
                    echo -e $tabla_final | cut -d ' ' -f1,2,3,4,5,6,7,8,9 | grep -v "?" | sort -n -r -k6 | column -t # Mostramos nuestra tabla solo consideranto los dispositivos con un numero mayor y menor
                else
                    echo "${TEXT_BOLD}Tipo  Nº Ocupa    M  m  Open Dispositivo UsoMayor PuntoDeMontaje ${TEXT_RESET}" # Encabezado
                    echo -e $tabla_final | cut -d ' ' -f1,2,3,4,5,6,7,8,9 | grep -v "?" | column -t # Mostramos nuestra tabla solo consideranto los dispositivos con un numero mayor y menor
                fi
            else
                if [ "$dispositivos_abiertos" == 1 ]; then
                    echo "${TEXT_BOLD}Tipo         Nº  Ocupacion  M  m   Dispositivo  UsoMayor   PuntoDeMontaje${TEXT_RESET}" # Encabezado
                    echo -e $tabla_final | cut -d ' ' -f1,2,3,4,5,6,7,8 | sort -n -r -k2 | column -t # Mostramos nuestra tabla solo consideranto los dispositivos con un numero mayor y menor
                elif [ "$archivos_abiertos" == 1 ]; then
                    echo "${TEXT_BOLD}Tipo         Nº  Ocupacion  M  m   Dispositivo  UsoMayor   PuntoDeMontaje${TEXT_RESET}" # Encabezado
                    echo -e $tabla_final | cut -d ' ' -f1,2,3,4,5,6,7,8 | sort -n -r -k6 | column -t # Mostramos nuestra tabla solo consideranto los dispositivos con un numero mayor y menor
                else
                    echo "${TEXT_BOLD}Tipo         Nº  Ocupacion  M  m   Dispositivo  UsoMayor   PuntoDeMontaje${TEXT_RESET}" # Encabezado
                    echo -e $tabla_final | cut -d ' ' -f1,2,3,4,5,6,7,8 | column -t # Mostramos nuestra tabla solo consideranto los dispositivos con un numero mayor y menor
                fi
            fi
        fi
    fi
}
# Función de ayuda de uso
usage() {
    echo "usage: ./filesysteminfo.sh [-inv] [-h] [-devicefiles] [-noheader] [-u user] [-sdevice]/[-sopen]"
}

# Función error
error_exit() {
    usage
    echo "$1" 1>&2
    exit 1
}

#Funcion comandos incmpatibles
error_comandos() {
    echo "$1" 1>&2
    echo "Los comando -sopen y -sdevice no pueden utilizarse juntos."
    exit 1
}

# OPCIONES 
while [ "$1" != "" ]; do
    case $1 in
        -u )
        usuario=1
        usuario_elegido=$2
        shift
        ;;

        -inv )
        inversa=1
        ;;

        -devicefiles )
        device=1
        ;;

        -noheader )
        noheaders=1
        ;;

        -sopen )
        archivos_abiertos=1
        ;;

        -sdevice )
        dispositivos_abiertos=1
        ;;

        -h | --help )
        usage
        exit
        ;;

        * )
        error_exit "El parámetro "$1" no existe para este programa."
    esac
    shift
done

# MAIN 
cat << _EOF_
$TEXT_BOLD$TITLE$TEXT_RESET

$(tabla)

$TEXT_GREEN$UPDATE$TEXT_RESET
_EOF_