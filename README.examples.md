# Some examples to follow in this directory

## Site with nginx server plus PHP app tier using MariaDB as backend and haproxy to load balance:

The solution uses Docker containers to Nginx, PHP and MariaDB. HAproxy in the host as well as one instance of Nginx to renew the certificate.

### Main files

 - dockerNginxPHPMariaDB.sh
 - dockerNginxPHPMariaDB.inv 
 - dockerNginxPHPMariaDB.yml
 - group\_vars/dockerNginxPHPMariaDB.yml
 - HAservers.inv
 - HAservers.yml
 - group\_vars/HAservers.yml
 - DBservers.inv
 - DBservers.yml
 - group\_vars/DBservers.yml

### Instructions

 - Be sure to have the key pair to connect to the server

 - The server must accept HTTP/HTTPS connections from internet on default ports (80/443) in which case will be handled by the HAproxy load balancer.

 - change internal hosts on HA Proxy config:
   - var file group\_vars/HAservers.yml
     - variable backend_srv_lines 

 - change db host in DB config:
   - var file group\_vars/DBservers.yml
     - variable db\_host (which will feed db\_list)
