#!/bin/bash
echo "Script para la agregacion de clientes del servidor del Cluster, NFS"
echo "Asegurate de ejecutarlo como administrador"
echo "Para ser ejecutado en centOS 7 y superior, con acceso a internet"
echo "Escrito para la clase de PC2"
#se solicita la ip del cliente del cluster en la red local
read -p "IP del cliente en red local y nombre(IP's del 10.0.1.3 al 10.0.1.100, usa npiuser por defecto): " ip_local nombre_pc
echo "$ip_local   $nombre_pc" >> /etc/hosts
echo "/nfs ${ip_local}(rw,sync,no_root_squash,no_subtree_check)" >> /etc/exports
echo "introduzca la contraseña de root del cliente (root por defecto)"
ssh root@$ip_local
#se agrega el usuario para trabajar en el cluster
adduser mpiuser
echo "Agrega la contraseña para mpiuser(se recomienda usar mpiuser si es solo un cluster de demostracion): "
passwd mpiuser
#se le dan permisos root al nuevo usuario
echo "mpiuser   ALL=(ALL)   ALL" >> /etc/sudoers
#se hace login como el nuevo usuario
#instalacion dependencias nfs
yum -y install nfs-utils nfs-utils-lib
mkdir -p /nfs
#se toma como predeterminada del servidor la direccion 10.0.1.2 
showmount -e 10.0.1.2
rpcinfo -p 10.0.1.2
#montaje disco de red en carpeta local
mount 10.0.1.2:/nfs /nfs
df -h
cd /nfs
touch sucess-$ip_local
echo $ip_local >> /nfs/hosts
#se guarda para proximo montaje
echo "10.0.1.2:/nfs /nfs nfs auto,noatime,nolock,bg,nfsvers=3,intr,tcp,actimeo=1800 0 0" >> /etc/fstab
#configuracion de ssh
cd /home/mpiuser
sudo -u mpiuser -H sh -c "mkdir .ssh"
#se copia desde el nfs la clave del servidor
cp /nfs/.ssh/id_rsa.pub .ssh
cp /nfs/.ssh/id_rsa .ssh
cd .ssh
#se copia la clave del servidor como clave segura
cp id_rsa.pub authorized_keys
#se agregan en el entorno del sistema los binarios y librerias de openmpi
echo export PATH=$PATH:/nfs/openmpi/bin >> ~/.bashrc
echo export LD_LIBRARY_PATH=/nfs/openmpi/lib >> ~/.bashrc
#se actualiza el entorno del sistema
source ~/.bashrc
exit
echo $nombre_pc >> /home/mpiuser/.mpi_hostfile
echo "cliente del cluster configurado correctamente"