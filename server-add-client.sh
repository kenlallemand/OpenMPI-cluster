#!/bin/bash
echo "Script para la agregacion de clientes del servidor del Cluster, NFS"
echo "Asegurate de ejecutarlo como root"
echo "Para ser ejecutado en centOS 7 y superior, con acceso a internet"
echo "Escrito para la clase de PC2"
#se solicita la ip del cliente del cluster en la red local
read -p "IP del cliente en red local (IP's del 10.0.1.3 al 10.0.1.100): " ip_local
#se solicita el nombre del equipo para su uso futuro en el cluster MPI
read -p "nombre pc cliente en el cluster (coloca un nombre unico para evitar coliciones: node1, node2...): " nombre_pc
#se guarda en el carchivo hosts
echo "$ip_local	$nombre_pc" >> /etc/hosts
echo "Agregado el cliente al archivo hosts para usar el nombre en lugar de su ip local :)"
#se agrega la ip del cliente en los permitidos del nfs para compartir la carpeta
echo "/nfs $ip_local(rw,sync,no_root_squash,no_subtree_check)" >> /etc/exports
exportfs -a
systemctl restart nfs
read -p "Introduzca la contraseña de root del cliente: " pass_ssh
#pd: se ejecutan los comandos por medio de ssh al cliente
sshpass -p $pass_ssh ssh -o StrictHostKeyChecking=no root@$ip_local 'adduser mpiuser'
#se agrega el usuario para trabajar en el cluster
echo "Agrega la contraseña para mpiuser(se recomienda usar mpiuser si es solo un cluster de demostracion): "
sshpass -p $pass_ssh ssh -o StrictHostKeyChecking=no root@$ip_local 'passwd mpiuser'
#se le dan permisos root al nuevo usuario
sshpass -p $pass_ssh ssh -o StrictHostKeyChecking=no root@$ip_local 'echo "mpiuser   ALL=(ALL)   ALL" >> /etc/sudoers'
#instalacion dependencias nfs
sshpass -p $pass_ssh ssh -o StrictHostKeyChecking=no root@$ip_local 'yum -y install nfs-utils wget'
sshpass -p $pass_ssh ssh -o StrictHostKeyChecking=no root@$ip_local 'mkdir -p /nfs'
#se toma como predeterminada del servidor la direccion 10.0.1.2
read -p "IP local del servidor (normalmente 10.0.1.2): " ip_server
#montaje disco de red en carpeta local
sshpass -p $pass_ssh ssh -o StrictHostKeyChecking=no root@$ip_local "mount $ip_server:/nfs /nfs"
sshpass -p $pass_ssh ssh -o StrictHostKeyChecking=no root@$ip_local 'mkdir /nfs/online_nodes/'
#se agrega la informacion de usuario y cuentas en la carpeta /nfs/online-nodes para uso facil
sshpass -p $pass_ssh ssh -o StrictHostKeyChecking=no root@$ip_local "touch /nfs/online_nodes/node_ip-${ip_local}"
sshpass -p $pass_ssh ssh -o StrictHostKeyChecking=no root@$ip_local "echo "$ip_local	nombre_pc" >> /nfs/online_nodes/node_ip-${ip_local}"
sshpass -p $pass_ssh ssh -o StrictHostKeyChecking=no root@$ip_local "cat /etc/passwd >> /nfs/online_nodes/node_ip-${ip_local}"
echo "$nombre_pc	$ip_local" >> /nfs/hosts
#se guarda para proximo montaje
sshpass -p $pass_ssh ssh -o StrictHostKeyChecking=no root@$ip_local "echo "$ip_server:/nfs /nfs nfs auto,noatime,nolock,bg,nfsvers=3,intr,tcp,actimeo=1800 0 0" >> /etc/fstab"
#Agregamos el montado automatico al inicio del sistema
sshpass -p $pass_ssh ssh -o StrictHostKeyChecking=no root@$ip_local 'echo "mount -a" >> /etc/rc.local'
sshpass -p $pass_ssh ssh -o StrictHostKeyChecking=no root@$ip_local 'echo "mount -a" >> /etc/rc.d/rc.local'
sshpass -p $pass_ssh ssh -o StrictHostKeyChecking=no root@$ip_local 'chmod +x /etc/rc.local'
sshpass -p $pass_ssh ssh -o StrictHostKeyChecking=no root@$ip_local 'chmod +x /etc/rc.d/rc.local'
#configuracion de ssh
#se copia desde el nfs la clave del servidor en la cuenta root
sshpass -p $pass_ssh ssh -o StrictHostKeyChecking=no root@$ip_local 'mkdir ~/.ssh'
sshpass -p $pass_ssh ssh -o StrictHostKeyChecking=no root@$ip_local 'cp /nfs/.ssh/id_rsa.pub /nfs/.ssh/id_rsa ~/.ssh'
#se copia la clave del servidor como clave segura
sshpass -p $pass_ssh ssh -o StrictHostKeyChecking=no root@$ip_local 'cp ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys'
#se copia desde el nfs la clave del servidor en la cuenta mpiuser
sshpass -p $pass_ssh ssh -o StrictHostKeyChecking=no root@$ip_local 'sudo -u mpiuser -H sh -c "mkdir /home/mpiuser/.ssh"'
sshpass -p $pass_ssh ssh -o StrictHostKeyChecking=no root@$ip_local 'sudo -u mpiuser -H sh -c "cp /nfs/.ssh/id_rsa.pub /home/mpiuser/.ssh"'
sshpass -p $pass_ssh ssh -o StrictHostKeyChecking=no root@$ip_local 'sudo -u mpiuser -H sh -c "cp /nfs/.ssh/id_rsa /home/mpiuser/.ssh"'
#se copia la clave del servidor como clave segura
sshpass -p $pass_ssh ssh -o StrictHostKeyChecking=no root@$ip_local 'sudo -u mpiuser -H sh -c "cp /home/mpiuser/.ssh/id_rsa.pub /home/mpiuser/.ssh/authorized_keys"'
#se agregan en el entorno del sistema los binarios y librerias de openmpi en la cuenta mpiuser
sshpass -p $pass_ssh ssh -o StrictHostKeyChecking=no root@$ip_local 'echo "export PATH=/nfs/openmpi/bin:$PATH" >> /home/mpiuser/.bashrc'
sshpass -p $pass_ssh ssh -o StrictHostKeyChecking=no root@$ip_local 'echo "export LD_LIBRARY_PATH=/nfs/openmpi/lib:$LD_LIBRARY_PATH" >> /home/mpiuser/.bashrc'
#se agregan en el entorno del sistema los binarios y librerias de openmpi en la cuenta root
sshpass -p $pass_ssh ssh -o StrictHostKeyChecking=no root@$ip_local 'echo "export PATH=/nfs/openmpi/bin:$PATH" >> ~/.bashrc'
sshpass -p $pass_ssh ssh -o StrictHostKeyChecking=no root@$ip_local 'echo "export LD_LIBRARY_PATH=/nfs/openmpi/lib:$LD_LIBRARY_PATH" >> ~/.bashrc'
#se actualiza el entorno del sistema
sshpass -p $pass_ssh ssh -o StrictHostKeyChecking=no root@$ip_local 'sudo -u mpiuser -H sh -c "source /home/mpiuser/.bashrc"'
sshpass -p $pass_ssh ssh -o StrictHostKeyChecking=no root@$ip_local 'source ~/.bashrc'
sshpass -p $pass_ssh ssh -o StrictHostKeyChecking=no root@$ip_local "echo "$ip_server	server" >> /etc/hosts"
echo $nombre_pc >> /home/mpiuser/.mpi_hostfile
echo $nombre_pc >> ~/.mpi_hostfile
#instalacion soporte python para mpi
cd /nfs
yum install -y python-pip mpi4py-openmpi
echo "cliente del cluster configurado correctamente"