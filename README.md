# Vagrant Server "Babbage"

Babbage is a servlet container's server for developers that runs:
  * Apache (port 8080)
  * MySQL server
  * Redmine (using MySQL instance)
  * PhpMyAdmin 
  * Tomcat servlet container (port 80)
  
Babbage runs into a vagrant machine (www.vagrantup.com) and has fix IP 192.168.1.95 on public network. You can change this settings by editing the Vagrantfile

Thanks to http://github.com/clalarco/vagrant-redmine from which I take the configuration of Redmine/MySQL!
