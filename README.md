# OpenMPI-cluster
Scripts para la creacion e inicializacion de servidor y nodos/clientes dentro de una red local, donde se desea crear un cluster con el protocolo MPI

**INSTRUCCIONES**

Para el correcto funcionamiento de los script por favor seguir las instrucciones al pie de la letra

1) si es un cluster en virtualbox(solo aplica para modo de prueba, se crea la red local virtual)
	ejecutar el siguiente comando en el directorio donde se encuentra el binario ejecutable de virtualbox
	VBoxManage dhcpserver add --netname intnet --ip 10.0.1.1 --netmask 255.255.255.0 --lowerip 10.0.1.2 --upperip 10.0.1.200 --enable
	conectar todas las maquinas virtuales a la red intnet en el adaptador de red 2

2) Ejecutar en la pc servidor el ejecutable server.sh para configurar el servidor (nfs, ssh con clave privada/publica y mpi por la implentacion openmpi compilado desde el codigo fuente, con soporte para fortran, c y c++)
3) Ejecutar server-add-client.sh desde el servidor para configurar completamente al cliente (acceso al nfs en su punto de montaje local, instalacion del no-password-login ssh y agregacion de los binarios de openmpi compartidos al entorno de usuario)
4) En caso de que la computadora cliente no permita conectar por ssh, se ejecuta client.sh en la maquina cliente.
5) disfruta :)
