# OpenMPI-cluster
Scripts para la creacion e inicializacion de servidor y nodos/clientes dentro de una red local, donde se desea crear un cluster con el protocolo MPI.
Se usa la implementacion de mpi OpenMPI debido a requerimientos del proyecto futuro uso planeado en las intel galileo.

**INSTRUCCIONES**

Para el correcto funcionamiento de los script por favor seguir las siguientes instrucciones:

1) si es un cluster en virtualbox(solo aplica para modo de prueba, se crea la red local virtual)
	ejecutar el siguiente comando en el directorio donde se encuentra el binario ejecutable de virtualbox
	VBoxManage dhcpserver add --netname intnet --ip 10.0.1.1 --netmask 255.255.255.0 --lowerip 10.0.1.2 --upperip 10.0.1.200 --enable
	conectar todas las maquinas virtuales a la red "intnet" en el adaptador de red 2.

2) Ejecutar en la pc servidor el ejecutable server.sh para configurar el servidor (nfs, ssh con clave privada/publica y openmpi compilado desde el codigo fuente, con soporte para c y c++).
3) Ejecutar server-add-client.sh desde el servidor para configurar completamente al cliente (acceso al nfs en su punto de montaje local, configuracion login sin autenticacion por ssh y agregacion de los binarios de openmpi compartidos al entorno de usuario local en el nodo).
4) En caso de que la computadora cliente no permita conectar por ssh, se ejecuta client.sh en la maquina cliente para instalar todas las dependencias faltantes.
5) disfruta :)

PD: Si al reiniciar no se encuentra montada la carpeta del servidor en el nodo, ejecutar "mount -a".
	El nodo puede ser accedido por el nombre dado previamente en lugar de su ip, ya que fue guardado en /etc/hosts.
