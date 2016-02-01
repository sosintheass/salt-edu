Vagrant.configure("2") do |config|
  config.vm.box = "debian/jessie64"

  config.vm.provider :virtualbox do |v|
    v.check_guest_additions = false
    v.functional_vboxsf     = false
    v.memory = 1024
    v.cpus = 2
  end

  config.vm.network :private_network, ip: "10.10.0.2"
  config.vm.hostname = "SaltEdu"
    
  config.vm.synced_folder "salt/roots/salt", "/srv/salt/"
  config.vm.synced_folder "salt/roots/pillar", "/srv/pillar/"

  config.vm.provision :salt do |salt|
    salt.minion_config = 'salt/minion'
    salt.run_highstate = true

    salt.pillar({
      "addkeyspace" => {
        "name" => "salt_edu_keyspace",
        "replication" => "{ 'class' : 'NetworkTopologyStrategy', 'datacenter1' : 3 }"
      }
    })
  end
 
end