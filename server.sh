#!/bin/bash
echo "Script para la creacion del servidor del Cluster, NFS"
echo "Asegurate de ejecutarlo como administrador"
echo "Para ser ejecutado en centOS 7 y superior, con acceso a internet"
echo "Escrito para la clase de PC2"
#creacion de usuario para uso en el cluster
su
adduser mpiuser
echo "Agrega la contraseña para mpiuser(se recomienda usar mpiuser si es solo un cluster de demostracion): "
passwd mpiuser
#se le dan permisos root al nuevo usuario
echo mpiuser ALL=(ALL=ALL) ALL >> /etc/sudoers
su - mpiuser
yum -y install nfs-utils nfs-utils-lib openssh-server
systemctl start rpcbind nfs-server
systemctl enable rpcbind nfs-server
mkdir /nfs
mkdir /nfs/projects
touch /nfs/hosts
echo read -p "IP local del servidor: " ip_pc
echo $ip_pc >> /nfs/hosts
#chmod 777 /nfs
exportfs -a
firewall-cmd --permanent --zone=public --add-service=nfs
firewall-cmd --permanent --zone=public --add-service=mountd
firewall-cmd --permanent --zone=public --add-service=rpc-bind
firewall-cmd --reload
systemctl restart nfs
#Configuracion de ssh y claves privadas/publicas
mkdir ~/.shh 
read -p "Nombre de usuario uninorte: " nombre_usuario
ssh-keygen -t rsa -b 4096 -C "$nombre_usuario@uninorte.edu.co"
echo "Se recomienda dejar en blanco las 3 siguientes preguntas de la consola, solo presionar enter."
\n
\n
\n
cd ~/.ssh
cp id_rsa authorized_keys
#se copia al nfs las llaves, para facilidad de acceso
mkdir /nfs/.ssh
cp ~/.ssh/id_rsa /nfs/.ssh
#---aqui comienza la configuracion con mpi---
#instalacion de dependencias
yum install -y gcc gcc-c++ make gcc-gfortran kernel-devel
#Obtenemos el codigo fuente con wget desde la pagina oficial
wget https://www.download.open-mpi.org/software/ompi/v3.1/openmpi-3.1.2.tar.gz
#descomprimimos
tar -zxvf openmpi-3.1.2.tar.gz
cd openmpi-3.1.2
#creamos el directorio que contendra los binarios de openmpi en nfs
mkdir /nfs/openmpi
#compilamos (este proceso tomara su tiempo)
#.configure -prefix=/nfs/openmpi CC=gcc CXX=g++ F77=gfortran FC=gfortran
.configure -prefix=/nfs/openmpi
make
make install
#agregamos al entorno del usuario
echo export PATH=$PATH:/nfs/openmpi/bin >> ~/.bashrc
echo export LD_LIBRARY_PATH=/nfs/openmpi/lib >> ~/.bashrc
source ~/.bashrc
#Compruebo donde esta el binario "mpirun"
which mpirun
echo "Ya esta listo, openmpi funcional con los compiladores de c, c++ y fortran, diviertete :)"
