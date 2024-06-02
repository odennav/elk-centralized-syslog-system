Vagrant.configure("2") do |config|
   
    config.vm.define "cs1" do |cs1|
      cs1.vm.box = "boxomatic/centos-stream-9"
      cs1.vm.hostname = "central-server1"
      cs1.vm.network "private_network", ip: "192.168.10.1"
      cs1.vm.synced_folder ".", "/vagrant"
      cs1.vm.provider "virtualbox" do |vb|
        vb.name = "cellusys-central1"
        vb.memory = "4096"
        vb.cpus = 2

      end  

    end

    config.vm.define "mp1" do |mp1|
      mp1.vm.box = "boxomatic/centos-stream-9"
      mp1.vm.hostname = "message-processor-1"
      mp1.vm.network "private_network", ip: "192.168.20.2"
      mp1.vm.synced_folder ".", "/vagrant"
      mp1.vm.provider "virtualbox" do |vb|
        vb.name = "cellusys-box1"
        vb.memory = "4096"
        vb.cpus = 2

      end  

    end

    config.vm.define "mp2" do |mp2|
      mp2.vm.box = "boxomatic/centos-stream-9"
      mp2.vm.hostname = "message-processor-2"
      mp2.vm.network "private_network", ip: "192.168.20.3"
      mp2.vm.synced_folder ".", "/vagrant"
      mp2.vm.provider "virtualbox" do |vb|
        vb.name = "cellusys-box2"
        vb.memory = "4096"
        vb.cpus = 2

      end  

    end


    config.vm.define "mp3" do |mp3|
      mp3.vm.box = "boxomatic/centos-stream-9"
      mp3.vm.hostname = "message-processor-3"
      mp3.vm.network "private_network", ip: "192.168.20.4"
      mp3.vm.synced_folder ".", "/vagrant"
      mp3.vm.provider "virtualbox" do |vb|
        vb.name = "cellusys-box3"
        vb.memory = "4096"
        vb.cpus = 2

      end  

    end


    config.vm.define "mp4" do |mp4|
      mp4.vm.box = "boxomatic/centos-stream-9"
      mp4.vm.hostname = "message-processor-4"
      mp4.vm.network "private_network", ip: "192.168.20.5"
      mp4.vm.synced_folder ".", "/vagrant"
      mp4.vm.provider "virtualbox" do |vb|
        vb.name = "cellusys-box4"
        vb.memory = "4096"
        vb.cpus = 2

      end  

    end



    config.vm.define "cs2" do |cs2|
      cs2.vm.box = "boxomatic/centos-stream-9"
      cs2.vm.hostname = "central-server2"
      cs2.vm.network "private_network", ip: "192.168.10.6"
      cs2.vm.synced_folder ".", "/vagrant"
      cs2.vm.provider "virtualbox" do |vb|
        vb.name = "cellusys-central2"
        vb.memory = "4096"
        vb.cpus = 2

      end  

    end    


    config.vm.define "mp5" do |mp5|
      mp5.vm.box = "boxomatic/centos-stream-9"
      mp5.vm.hostname = "message-processor-5"
      mp5.vm.network "private_network", ip: "192.168.20.7"
      mp5.vm.synced_folder ".", "/vagrant"
      mp5.vm.provider "virtualbox" do |vb|
        vb.name = "cellusys-box5"
        vb.memory = "4096"
        vb.cpus = 2

      end  

    end

    config.vm.define "js" do |js|
      js.vm.box = "boxomatic/centos-stream-9"
      js.vm.hostname = "jenkins-slave-1"
      js.vm.network "private_network", ip: "192.168.10.8"
      js.vm.synced_folder ".", "/vagrant"
      js.vm.provider "virtualbox" do |vb|
        vb.name = "jenkins-agent"
        vb.memory = "4096"
        vb.cpus = 2

      end  

    end    


end


