#!/bin/bash
echo "Script para la agregacion de clientes del servidor del Cluster, NFS"
echo "Asegurate de ejecutarlo como root"
echo "Para ser ejecutado en centOS 7 y superior, con acceso a internet"
echo "Escrito para la clase de PC2"
#se solicita la ip del cliente del cluster en la red local
read -p "IP del cliente en red local (IP's del 10.0.1.3 al 10.0.1.100): " 
#se solicita el nombre del equipo para su uso futuro en el cluster MPI
read -p "nombre pc cliente en el cluster (coloca un nombre unico para evitar coliciones: node1, node2...): " nombre_pc
#se guarda en el carchivo hosts
echo "$ip_local	$nombre_pc" >> /etc/hosts
echo "Agregado el cliente al archivo hosts para usar el nombre en lugar de su ip local :)"
#se agrega la ip del cliente en los permitidos del nfs para compartir la carpeta
echo "/nfs ${ip_local}(rw,sync,no_root_squash,no_subtree_check)" >> /etc/exports
read -p "Introduzca la contraseña de root del cliente: " pass_ssh
echo $pass_ssh
pass_ssh="root"
echo $pass_ssh
#pd: se ejecutan los comandos por medio de ssh al cliente
#Agregacion de usuario
ssh root@$ip_local "adduser mpiuser"
#se agrega el usuario para trabajar en el cluster
echo "Agrega la contraseña para mpiuser(se recomienda usar mpiuser si es solo un cluster de demostracion): "
sshpass -p $pass_ssh ssh root@$ip_local'passwd mpiuser'
#se le dan permisos root al nuevo usuario
sshpass -p $pass_ssh ssh root@$ip_local 'echo "mpiuser   ALL=(ALL)   ALL" >> /etc/sudoers'
#instalacion dependencias nfs
sshpass -p $pass_ssh ssh root@$ip_local 'yum -y install nfs-utils wget'
sshpass -p $pass_ssh ssh root@$ip_local 'mkdir -p /nfs; chmod -R 777 /nfs'
#se toma como predeterminada del servidor la direccion 10.0.1.2
read -p "IP local del servidor (normalmente 10.0.1.2): " ip_pc
sshpass -p $pass_ssh ssh root@$ip_local 'showmount -e $ip_pc; rpcinfo -p $ip_pc'
#montaje disco de red en carpeta local
sshpass -p $pass_ssh ssh root@$ip_local 'mount ${ip_pc}:/nfs /nfs'
sshpass -p $pass_ssh ssh root@$ip_local 'df -h'
sshpass -p $pass_ssh ssh root@$ip_local 'cd /nfs'
sshpass -p $pass_ssh ssh root@$ip_local 'touch /nfs/sucess-${ip_local}'
echo "$HOSTNAME	$ip_local" >> /nfs/hosts
#se guarda para proximo montaje
sshpass -p $pass_ssh ssh root@$ip_local 'echo "${ip_pc}:/nfs /nfs nfs auto,noatime,nolock,bg,nfsvers=3,intr,tcp,actimeo=1800 0 0" >> /etc/fstab'
#configuracion de ssh
#se copia desde el nfs la clave del servidor
sshpass -p $pass_ssh ssh root@$ip_local 'sudo -u mpiuser -H sh -c "mkdir /home/mpiuser/.ssh"'
sshpass -p $pass_ssh ssh root@$ip_local 'sudo -u mpiuser -H sh -c "cp /nfs/.ssh/id_rsa.pub /home/mpiuser/.ssh"'
sshpass -p $pass_ssh ssh root@$ip_local 'sudo -u mpiuser -H sh -c "cp /nfs/.ssh/id_rsa /home/mpiuser/.ssh"'
#se copia la clave del servidor como clave segura
sshpass -p $pass_ssh ssh root@$ip_local 'sudo -u mpiuser -H sh -c "cp /home/mpiuser/.ssh/id_rsa.pub /home/mpiuser/authorized_keys"'
#se agregan en el entorno del sistema los binarios y librerias de openmpi
sshpass -p $pass_ssh ssh root@$ip_local 'echo "export PATH=/nfs/openmpi/bin:$PATH" >> /home/mpiuser/.bashrc'
sshpass -p $pass_ssh ssh root@$ip_local 'echo "export LD_LIBRARY_PATH=/nfs/openmpi/lib:$LD_LIBRARY_PATH" >> /home/mpiuser/.bashrc'
#se actualiza el entorno del sistema
sshpass -p $pass_ssh ssh root@$ip_local 'sudo -u mpiuser -H sh -c "source /home/mpiuser/.bashrc"'
exit
echo $nombre_pc >> /home/mpiuser/.mpi_hostfile
echo "cliente del cluster configurado correctamente"