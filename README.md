# Vagrant Server "Babbage"

Babbage is a servlet container's server for developers that runs:
  * Apache (port 8080)
  * MySQL server
  * Redmine (using MySQL instance)
  * PhpMyAdmin 
  * Tomcat servlet container (port 80)
  
Babbage runs into a vagrant machine (www.vagrantup.com) and has a fix IP 192.168.33.21 on private network. You can change this settings by editing the Vagrantfile. The vagrant is ready to be published on public network with IP 192.168.1.95.

Thanks to http://github.com/clalarco/vagrant-redmine from which I take the configuration of Redmine/MySQL!
