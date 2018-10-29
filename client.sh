#!/bin/bash
echo "Script para la creacion de un cliente del Cluster openmpi"
echo "Asegurate de ejecutarlo como root"
echo "Para ser ejecutado en centOS 7 y superior, con acceso a internet de banda ancha, y en una red local junto con el servidor"
echo "Escrito para la clase de Estructura del computador 2"
echo "Este script solo debe ser ejecutado si no se puede conectar con el cliente debido a la falta del ssh/dependencias
#instalar dependencias
yum -y install openssh-server openssh-clients nfs-utils
echo "Configuracion basica finalizada correctamente, procede a agregar el nodo con el script "server-add-client.sh" ejecutado desde el nodo maestro/servidor"
