#!/bin/bash
echo "Script para la creacion del servidor del Cluster, NFS"
echo "Asegurate de ejecutarlo como root"
echo "Para ser ejecutado en centOS 7 y superior, con acceso a internet"
echo "Escrito para la clase de PC2"
#creacion de usuario para uso en el cluster
adduser mpiuser
echo 'Agrega la contraseña para mpiuser(se recomienda usar mpiuser si es solo un cluster de demostracion): '
passwd mpiuser
#Agregacion de permisos root al usuario recientemente creado
echo "mpiuser   ALL=(ALL)   ALL" >> /etc/sudoers
yum -y install nfs-utils openssh-server nano sshpass
systemctl start rpcbind nfs-server
systemctl enable rpcbind nfs-server
mkdir /nfs
mkdir /nfs/projects
touch /nfs/hosts
read -p "IP local del servidor: " ip_pc
echo "$HOSTNAME	$ip_pc" >> /nfs/hosts
#Arrancamos los servicios y colocamos las excepciones en el firewall
exportfs -a
firewall-cmd --permanent --zone=public --add-service=nfs
firewall-cmd --permanent --zone=public --add-service=mountd
firewall-cmd --permanent --zone=public --add-service=rpc-bind
firewall-cmd --reload
systemctl restart nfs
#Configuracion de ssh y claves privadas/publicas
read -p "Nombre de usuario uninorte: " nombre_usuario
sudo -u mpiuser -H sh -c "pwd; mkdir /home/mpiuser/.ssh"
sudo -u mpiuser -H sh -c "ssh-keygen -t rsa -b 4096 -C "${nombre_usuario}@uninorte.edu.co""
echo "Se recomienda dejar en blanco las 3 siguientes preguntas de la consola, solo presionar enter."
#copiando las claves de la carpeta donde se guardan
cd /home/mpiuser/.ssh
sudo -u mpiuser -H sh -c "cp id_rsa.pub authorized_keys"
#se copian a la carpeta root las llaves, para el login automatico
cp -r /home/mpiuser/.ssh ~/.ssh
#se copia al nfs las llaves, para facilidad de acceso
mkdir /nfs/.ssh
chmod -R 777 /nfs
sudo -u mpiuser -H sh -c "cp /home/mpiuser/.ssh/id_rsa /nfs/.ssh"
sudo -u mpiuser -H sh -c "cp /home/mpiuser/.ssh/id_rsa.pub /nfs/.ssh"
#---aqui comienza la configuracion con mpi---
#instalacion de dependencias (quitamos gcc-gfortran)
yum install -y gcc gcc-c++ make kernel-devel wget
#regresamos al directorio de la carpeta compartida
cd /nfs
#Obtenemos el codigo fuente de la la pagina oficial con wget
wget https://download.open-mpi.org/release/open-mpi/v3.1/openmpi-3.1.2.tar.gz
#descomprimimos
tar -zxvf openmpi-3.1.2.tar.gz
cd openmpi-3.1.2
#creamos el directorio que contendra los binarios de openmpi en nfs
mkdir /nfs/openmpi
chmod 777 /nfs/openmpi
#compilamos (este proceso tomara su tiempo, para reducirlo hemos desactivado fortran)
# parametros adicionales a probar ../configure --prefix=/opt/openmpi --with-devel-headers --enable-binaries
./configure -prefix=/nfs/openmpi --disable-fortran
make
make install
#agregamos al entorno del usuario
echo "export PATH=/nfs/openmpi/bin:$PATH" >> /home/mpiuser/.bashrc
echo "export LD_LIBRARY_PATH=/nfs/openmpi/lib:$LD_LIBRARY_PATH" >> /home/mpiuser/.bashrc
#agregamos al entorno de root
echo "export PATH=/nfs/openmpi/bin:$PATH" >> ~/.bashrc
echo "export LD_LIBRARY_PATH=/nfs/openmpi/lib:$LD_LIBRARY_PATH" >> ~/.bashrc
sudo -u mpiuser -H sh -c "source ~/.bashrc"
#limpio la carpeta /nfs con el codigo fuente no necesario
rm -rf /nfs/openmpi-3.1.2
rm -rf /nfs/openmpi-3.1.2.tar.gz
#Compruebo donde esta el binario "mpirun"
#para root
which mpirun
#para mpiuser
sudo -u mpiuser -H sh -c "which mpirun"
#se instala el soporte para mpi4python
#pip install mpi4py
yum install -y python-pip mpi4py-openmpi
echo "Ya esta listo, openmpi funcional con los compiladores de c, c++ y fortran, diviertete :)"
cd /nfs/openmpi/projects
