# Elasticsearch Centralized Logging System

The ELK stack consists of Elasticsearch, Logstash, and Kibana.

They provide a powerful, flexible, and scalable solution for managing and making sense of large amounts of data.

**`Logstash`**: a data processing pipeline which gathers, processes and forwards data (logs, metrics) from various sources to Elasticsearch.

**`Elasticsearch`**: a distributed search and analytics engine that stores this processed data and enables powerful search and analytics capabilities.

**`Kibana`**: a data visualization and exploration tool. It provides a graphical interface to visualize and explore the data stored in Elasticsearch.

![](https://github.com/odennav/elk-centralized-syslog-system/blob/main/docs/ELK%20Syslog%20System.png)

**Benefits of ELK Stack**

**`Real-time Insights`**: They enable real-time data processing and visualization, which is crucial for monitoring and quick decision-making.

**`Scalability`**: They can handle large-scale data operations, making them suitable for big data applications.

**`Flexibility`**: They support a wide range of data types and sources, providing flexibility in how data is ingested, stored, and analyzed.


## Getting Started

We'll implement the workflow below:

- Provision Central Server

- User Configuration on Linux Servers

- Setup ELK Stack in Central Server

- Enable ELK Clustering

- Add Remote Hosts 

- Develop Kibana Visualization

- Create Kibana Dashboard

-----

## Provision Central Server

Eight linux servers are provisioned with Vagrant in this lab. Use Vagrantfile in this repository.

**Install Vagrant**

If you haven't installed Vagrant for this lab, download it here and follow the installation instructions for your OS.

If you encounter an issue with Windows, you might get a blue screen upon attempt to bring up a VirtualBox VM with Hyper-V enabled.

To use VirtualBox on Windows, ensure Hyper-V is not enabled. Then turn off the feature with the following Powershell commands:

```bash
Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
bcdedit /set hypervisorlaunchtype off
```

After reboot of your local machine, run:

```bash
vagrant up cs1
vagrant ssh cs1
```

-----

## User Configuration on Linux Servers

Add New User

We'll use cs1 virtual machine as our build machine. Integrations to pipeline is implemented on this server

Change password for root user

```bash
sudo passwd
```

Switch to root user. Add new user 'odennav' to sudo group.
```bash
sudo useradd odennav
sudo usermod -aG wheel odennav
```

Notice the prompt to enter your user password. To disable password prompt for every sudo command, implement the following:

Add sudoers file for odennav-admin
```bash
echo "odennav ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/odennav
```

Ensure correct permissions for sudoers file
```bash
sudo chmod 0440 /etc/sudoers.d/odennav
sudo chown root:root /etc/sudoers.d/odennav
```

Test sudo privileges by switching to new user

```bash
su - odennav
sudo ls -la /root
```

To change the PermitRootLogin setting, modify the SSH server configuration file /etc/ssh/sshd_config as shown below:

```bash
PermitRootLogin no
```

Restart the SSH service for the changes to take effect
```bash
sudo systemctl restart sshd
```

Verify the the configuration has been applied

```bash
sudo grep PermitRootLogin /etc/ssh/sshd_config
```

-----

## Setup ELK Stack in Central Server


**Install Elasticsearch with RPM**

Download from elastic website and install the RPM manually 
```bash
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.13.4-x86_64.rpm
```


Download the SHA512 checksum file
```bash
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.13.4-x86_64.rpm.sha512
```

Verify the checksum
```bash
shasum -a 512 -c elasticsearch-8.13.4-x86_64.rpm.sha512
```

Comparing the SHA of the downloaded RPM and the published checksum, should output 
```text
elasticsearch-8.13.4-x86_64.rpm: OK.
```

When the checksums match, this confirms that the file is intact and hasn't been tampered with.

Install the RPM
```bash
sudo rpm --install elasticsearch-8.13.4-x86_64.rpm
```

When installing Elasticsearch, security features are enabled and configured by default.

The password and certificate and keys are output to your terminal.

Store the elastic password as an environment variable in your shell.

```bash
export ELASTIC_PASSWORD="my_password"
```

Name Elasticsearch Cluster
```bash
sudo vi /etc/elasticsearch/elasticsearch.yml
```

For a production environment, it's beneficial to have shards distributed. We'll configure elasticsearch to communicate with outside network and look for an additional node, `cs2`.
 
Add this to end of `elasticsearch.yml` and save the configuration.

```bash
cluster.name: syslog
node.name: cs1
network.host: [192.168.10.1, _local_]
discovery.zen.ping.unicast.hosts: ["192.168.10.1", "192.168.10.6"]
action.auto_create_index: .monitoring*,.watches,.triggered_watches,.watcher-history*,.ml*
```

Start and enable elasticsearch service
```
sudo systemctl daemon-reload
sudo systemctl start elasticsearch.service
sudo systemctl enable elasticsearch.service
```

Confirm connection to elasticsearch
```bash
curl --cacert /etc/elasticsearch/certs/http_ca.crt -u elastic:$ELASTIC_PASSWORD https://localhost:9200 
```


**Install Logstash with RPM**

Ensure java is available for Logstash
```bash
sudo yum install -y java-1.8.0-openjdk
```

Download and install the public signing key
```bash
sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
```

Create `logstash.repo` in `/etc/yum.repos.d/`
```bash
cd /etc/yum.repos.d/
sudo touch logstash.repo
```

Add this to `logstash.repo` file
```text
[logstash-8.x]
name=Elastic repository for 8.x packages
baseurl=https://artifacts.elastic.co/packages/8.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
```

Install logstash
```bash
sudo yum install logstash
```


**Configure Logstash**

Create the syslog configuration file for logstash
```bash
sudo touch /etc/logstash/conf.d/syslog.conf
```

Our logstash configuration will have three main blocks:

- **`Input`**: cause logstash to listen for syslog messages on port 5141

- **`Filter`**: process messages it receives that match the given patterns.
  
  It extracts the authentication method, the username, the source IP address, and source   
  port for ssh connection attempts. Also tags the messages with "ssh_successful_login" or
  "ssh_failed_login".

- **`Output`**:  store the messages into the elasticsearch instance we just created.

Add this to `syslog.conf` and save the configuration
```text
input {
  syslog {
    type => syslog
    port => 5141
  }
}

filter {
  if [type] == "syslog" {
    grok {
      match => { "message" => "Accepted %{WORD:auth_method} for %{USER:username} from %{IP:src_ip} port %{INT:src_port} ssh2" }
      add_tag => "ssh_successful_login"
    }
    grok {
      match => { "message" => "Failed %{WORD:auth_method} for %{USER:username} from %{IP:src_ip} port %{INT:src_port} ssh2" }
      add_tag => "ssh_failed_login"
    }
    grok {
      match => { "message" => "Invalid user %{USER:username} from %{IP:src_ip}" }
      add_tag => "ssh_failed_login"
    }
  }
  geoip {
    source => "src_ip"
  }
}

output {
  elasticsearch { }
}

```

Start and enable logstash service
```bash
sudo systemctl start logstash.service
sudo systemctl enable logstash.service
```

**Forward Syslogs to Logstash**

Next, we configure `cs1` node tp forward its syslog messages to logstash.

Create logstash configuration file
```bash
sudo touch /etc/rsyslog.d/logstash.conf
```
Add this to `logstash.conf` and save
```bash
*.* @192.168.10.1:5141
```
 

Restart rsyslog service
```bash
sudo systemctl restart rsyslog
```

Confirm logstash is now receiving syslog messages from `cs1` node and and storing them in Elasticsearch.

```bash
curl --cacert /etc/elasticsearch/certs/http_ca.crt -u elastic:$ELASTIC_PASSWORD https://localhost:9200/_cat/indices?v
```


**Install Kibana**

Download from elastic website and install the RPM manually 
```bash
wget https://artifacts.elastic.co/downloads/kibana/kibana-8.13.4-x86_64.rpm
```

Download the SHA512 checksum file
```bash
shasum -a 512 -c kibana-8.13.4-x86_64.rpm.sha512
```

Verify the checksum
```bash
shasum -a 512 -c kibana-8.13.4-x86_64.rpm.sha512
```

Comparing the SHA of the downloaded RPM and the published checksum, should output 
```text
kibana-8.13.4-x86_64.rpm: OK
```

Install the RPM 
```bash
sudo rpm --install kibana-8.13.4-x86_64.rpm
```

To enable connection to Kibana from outside the localhost
```bash
sudo vi /etc/kibana/kibana.yml
```

Add this to the configuration file, `kibana.yml`
```bash
server.host: "192.168.10.1"
```

**Securely connect kibana with elasticsearch**

The elasticsearch-create-enrollment-token command creates enrollment tokens for Elasticsearch nodes and Kibana instances.

Generate an enrollment token for kibana
```bash
/usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana
```

Start and enable kibana service
```bash
sudo systemctl daemon-reload
sudo systemctl start kibana.service
sudo systemctl enable kibana.service
```

To receive feedback whether Kibana was started successfully or not
```bash
sudo journalctl -u kibana.service
```

Browse `192.168.10.1:5601` to view Kibana UI and click on `Explore on my own` link to get started with Elastic.

                     ![](https://github.com/odennav/elk-centralized-syslog-system/blob/main/docs/view_kibana.png)

-----

## Enable ELK CLustering

**Configure Node to Join Cluster**

When Elasticsearch was installed in first node `cs1`, the installation process configured a single-node cluster by default.

To enable a node to join an existing cluster instead, implement the following:

1. Generate an enrollment token on an existing node, `cs1` before you start the new node 
`cs2` for the first time.

 On `cs1` in our existing cluster, generate a node enrollment token

```bash
/usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s node
```

2. Copy the enrollment token, which is output to your terminal.

3. Start `cs2` local machine, run:

```bash
vagrant up cs2
vagrant ssh cs2
```

We'll use `cs2` node as our additional elasticsearch cluster member.

4. Implement the same steps done for `cs1` node in `cs2` node:

- Install Elasticsearch

- Install Logstash

- Install Kibana


5. Ensure elasticsearch cluster in second node is named

```bash
sudo vi /etc/elasticsearch/elasticsearch.yml
```

Add this to end of `elasticsearch.yml` and save the configuration.

```bash
cluster.name: syslog
node.name: cs2
network.host: [192.168.10.6, _local_]
discovery.zen.ping.unicast.hosts: ["192.168.10.1", "192.168.10.6"]
action.auto_create_index: .monitoring*,.watches,.triggered_watches,.watcher-history*,.ml*
```

This new second server will automatically discover and join the cluster as long as it has the same `cluster.name` as the first node.


6. On your new Elasticsearch node, `cs2`, pass the enrollment token generated in step1 as a parameter to the elasticsearch-reconfigure-node tool
```bash
/usr/share/elasticsearch/bin/elasticsearch-reconfigure-node --enrollment-token <enrollment-token>
```

Start and enable elasticsearch service
```
sudo systemctl daemon-reload
sudo systemctl start elasticsearch.service
sudo systemctl enable elasticsearch.service
```

-----

## Add Remote Hosts 

Start other remote machines, run:

```bash
vagrant up 
vagrant ssh 
```

**Install Ansible**

To install ansibe without upgrading current python version, we'll make use of the yum packae manager.
```bash
sudo yum update
sudo yum upgrade
```

Install EPEL repository
```bash
sudo yum install epel-release
```

Verify installation of EPEL repository
```bash
sudo yum repolist
```

Install Ansible
```bash
sudo yum install ansible
```

Confirm installation
```bash
ansible --version
```

**Configure Ansible Vault**

Ansible communicates with target remote servers using SSH and usually we generate RSA key pair and copy the public key to each remote server, instead we'll use username and password credentials of odennav user.

This credentials are added to inventory host file but encrypted with ansible-vault

Ensure all IPv4 addresses and user variables of remote servers are in the inventory file as shown

View ansible-vault/values.yml which has the secret password

```bash
cat /elk-centralized-logging-system/ansible/ansible-vault/values.yml
```

Generate vault password file
```bash
openssl rand -base64 2048 > /elk-centralized-logging-system/ansible/ansible-vault/secret-vault.pass
```

Create ansible vault with vault password file
```bash
ansible-vault create /elk-centralized-logging-system/ansible/ansible-vault/values.yml --vault-password-file=/elk-centralized-logging-system/ansible/ansible-vault/secret-vault.pass
```

View content of ansible vault
```bash
ansible-vault view /elk-centralized-logging-system/ansible/ansible-vault/values.yml --vault-password-file=/elk-centralized-logging-system/ansible/ansible-vault/secret-vault.pass
```

Read ansible vault password from environment variable
```bash
export ANSIBLE_VAULT_PASSWORD_FILE=/elk-centralized-logging-system/ansible/ansible-vault/secret-vault.pass
```

Confirm environment variable has been exported
```bash
export ANSIBLE_VAULT_PASSWORD_FILE
```

Test Ansible by pinging all remote servers in inventory list
```bash
ansible all -m ping
```

**Configure Remote Hosts**

We'll use ansible playbook to configure the remote systems to forward their syslog messages to the centralized syslog server.

```bash
ansible-playbook -i hosts.inventory /elk-centralized-logging-system/ansible/add_hosts/add_hosts.yml
```

**Create Index Pattern**

Impplement the following steps below:

- Return to the Kibana UI at `192.168.10.1:5601`.

- Click on the hamburger menu icon, then click on the **`Stack Management`** link under the **`Management`** section of the menu.

![](https://github.com/odennav/elk-centralized-syslog-system/blob/main/docs/stack_mgt.png)

- Scroll down. Under the **`Kibana`** section, click the **`Index Patterns`** link.

![](https://github.com/odennav/elk-centralized-syslog-system/blob/main/docs/index_paterns.png)

- There will be a pop-up display labeled `About Index Patterns` in the right-hand side of your screen. Click the `x` to close it.

- Now click on the `Create index pattern` button.

![](https://github.com/odennav/elk-centralized-syslog-system/blob/main/docs/create_index_pattern.png)

- In the `Index pattern name` field, enter `logstash*` and then click `Next Step >` button. 
 
![](https://github.com/odennav/elk-centralized-syslog-system/blob/main/docs/index_pattern_name.png)

  This tells Kibana to use any indices in Elasticsearch that start with `logstash`.

- In the `Time Field` dropdown menu, select `@timestamp`, then click the `Create index pattern` button.

![](https://github.com/odennav/elk-centralized-syslog-system/blob/main/docs/timestamp.png)

 A screen will appear that shows information about the index pattern that we've just created.

![](https://github.com/odennav/elk-centralized-syslog-system/blob/main/docs/logstash_index_pattern.png)


**Confirm Log Sources from Remote Hosts**

Now we can start searching for log messages

- Click on the hamburger menu icon, then click on the **`Discover`** link under the **`Kibana`** section of the menu.

![](https://github.com/odennav/elk-centralized-syslog-system/blob/main/docs/discover.png)

- At the left-hand **`field`** menu, click on **`logsource`**.
 
You should now see the other remote hosts appear in addition to the `cs1` host.

Now you can search forlog records across multiple hosts in one single place. 

-----

## Develop Kibana Dashboard

**Generate Syslog**

We'll use two scripts in `syslog-gen` directory to simulate syslog generation.

The logstash config will process and filter this messages, while also tagging them.

We can then search for this syslog records stored in elasticsearch and visually analyze with Kibana.

**Create Kibana Visualization**

Next, we use Kibana to create a visualization object that analyzes the unsuccessful `ssh login` data.

Implement the following steps:

- Click on the hamburger menu icon, then click on the **`Visualize`** link under the **`Kibana`** section of the menu.

- Click on the `Create new visualization` button.

- Scroll down and click `Vertical Bar`.

![](https://github.com/odennav/elk-centralized-syslog-system/blob/main/docs/vertical_bar.png)

- Next, click on `logstash*` index pattern.

![](https://github.com/odennav/elk-centralized-syslog-system/blob/main/docs/logstash_icon.png)

- In the search bar, type in `tags:ssh_failed_login` and click on the `Refresh` button. Set date as `Last 1 hour` to capture events of multiple failed ssh login attempts.

-  Under "Buckets", click on the `+ Add` link. The click on `X-Axis`. 

- Under aggregation, select `Date Histogram`. To apply the changes, click the `Update` button at the bottom-right of your screen.

- Now we'll see that one big bar break into smaller bars.

  When you hover over the bar, it tells us the number of times the search occurs during that time period. 

- Under the `Metrics` Section, click on `Y-Axis`. Now supply a
custom label of `Failed Logins`.

 To apply this change, click the `Update` button in the bottom-right of your screen.

- Finally, click the `Save` icon in the top-left and give this graph a Title of `Failed SSH Logins`. Click `Save`.


**Use Kibana Dashboard**

Next, we use Kibana to create a dashboard for the the unsuccessful `ssh login` visualization object we just created.


Implement the following steps:

- Click on the hamburger menu icon, then click on the **`Dashboard`** link under the **`Kibana`** section of the menu.

- Click on the `Create new dashboard` button.

![](https://github.com/odennav/elk-centralized-syslog-system/blob/main/docs/create_new_dashboard.png)

- Click on the `Add an existing object` link, then click on `Failed SSH Logins`. 

  Next, click on the `x` to close the pop-up window.

  Adjust the graph to whatever size you desire.

- Click on the `save` link at the top of your screen and name the dashboard `SSH Login Analysis" then save it.

The visualization object enables us to represent the syslog data in a meaningful way and also adding them to a dashboard for real-time view.

-----

Enjoy!


