# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  # Build up to 10 el7 machines. psdevtools-el7-0 is the default that will be the primary and 
  # autostart. Subsequent machines will not autostart. Each will have a full pscheduler 
  # install and maddash-server. The souce will live under /vagrant. You can access 
  # /etc/perfsonar in the shared directory /vagrant-data/vagrant/{hostname}/etc/perfsonar. 
  # Port forwarding is setup and hosts are on a private network with static IPv4 and IPv6 
  # addresses
  (0..9).each do |i|
      config.vm.define "psdevtools-el7-#{i}", primary: (i == 0), autostart: (i == 0) do |psdevtools|
        # set box to official CentOS 7 image
        psdevtools.vm.box = "centos/7"
        # explcitly set shared folder to virtualbox type. If not set will choose rsync 
        # which is just a one-way share that is less useful in this context
        psdevtools.vm.synced_folder ".", "/vagrant", type: "virtualbox"
        # Set hostname
        psdevtools.vm.hostname = "psdevtools-el7-#{i}"
        
        # Enable IPv4. Cannot be directly before or after line that sets IPv6 address. Looks
        # to be a strange bug where IPv6 and IPv4 mixed-up by vagrant otherwise and one 
        #interface will appear not to have an address. If you look at network-scripts file
        # you will see a mangled result where IPv4 is set for IPv6 or vice versa
        psdevtools.vm.network "private_network", ip: "10.1.1.100"
        
        #Disable selinux
        psdevtools.vm.provision "shell", inline: <<-SHELL
            sed -i s/SELINUX=enforcing/SELINUX=permissive/g /etc/selinux/config
        SHELL
    
        #Install all requirements and perform initial setup
        psdevtools.vm.provision "shell", inline: <<-SHELL
            yum install -y epel-release
            yum install -y  http://software.internet2.edu/rpms/el7/x86_64/RPMS.main/perfSONAR-repo-0.8-1.noarch.rpm
            yum clean all
            yum install -y gcc\
                kernel-devel\
                kernel-headers\
                dkms\
                make\
                bzip2\
                perl\
                perl-devel\
                python\
                git
        SHELL
      end
  end
end
