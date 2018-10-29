#!/bin/bash
echo "Script para la agregacion de clientes del servidor del Cluster, NFS"
echo "Asegurate de ejecutarlo como root"
echo "Para ser ejecutado en centOS 7 y superior, con acceso a internet"
echo "Escrito para la clase de PC2"
read -p "Introduzca la contraseña de root del cliente: " pass_ssh
read -p "IP local del servidor (normalmente 10.0.1.2): " ip_server
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
echo $nombre_pc >> /home/mpiuser/.mpi_hostfile
echo $nombre_pc >> ~/.mpi_hostfile
#instalacion soporte python para mpi
cd /nfs
yum install -y python-pip mpi4py-openmpi