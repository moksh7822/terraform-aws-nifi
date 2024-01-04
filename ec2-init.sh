#!/bin/bash
sudo apt-get update -y
sudo apt-get upgrade -y

#Install Java
sudo apt install openjdk-17-jdk openjdk-17-jre -y
echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64' | sudo tee -a /etc/profile
echo 'PATH=$PATH:$JAVA_HOME/bin' | sudo tee -a /etc/profile
source /etc/profile

function prop_replace() {
    local filepath=$1
    local propname=$2
    local propvalue=$3
    local delim="="
    
    #Check if file exists
    if [ ! -f "${filepath}" ]; then
       echo "File '${filepath}' does not exist"
       return 1
    fi
    
    #Escape forward slashes in property value
    propvalue=${propvalue//\//\\/}
    
    #Replace property in file
    sed -i -e "s|^${propname}${delim}.*|${propname}${delim}${propvalue}|" "${filepath}"
    
    return 0
  }
 # Install unzip
sudo apt-get install unzip -y
 
#Install nifi
cd /home/ubuntu && wget https://archive.apache.org/dist/nifi/1.19.1/nifi-1.19.1-bin.zip
unzip /home/ubuntu/nifi-1.19.1-bin.zip
mv /home/ubuntu/nifi-1.19.1 /home/ubuntu/nifi 

# Install toolkit
wget https://archive.apache.org/dist/nifi/1.19.1/nifi-toolkit-1.19.1-bin.zip
unzip /home/ubuntu/nifi-toolkit-1.19.1-bin.zip
mv /home/ubuntu/nifi-toolkit-1.19.1 /home/ubuntu/nifi-toolkit
chown -R ubuntu: /home/ubuntu/*

#Configure nifi cluster
prop_replace /home/ubuntu/nifi/conf/nifi.properties "nifi.web.http.port" "8443"
prop_replace /home/ubuntu/nifi/conf/nifi.properties "nifi.web.http.host" "<nifi-hostname>"
prop_replace /home/ubuntu/nifi/conf/nifi.properties "nifi.content.claim.max.appendable.size" "1MB"
prop_replace /home/ubuntu/nifi/conf/nifi.properties "nifi.provenance.repository.max.storage.time" "24 hours"
prop_replace /home/ubuntu/nifi/conf/nifi.properties "nifi.remote.input.socket.port" "9997"
prop_replace /home/ubuntu/nifi/conf/nifi.properties "nifi.remote.input.host" "<nifi-hostname>"
prop_replace /home/ubuntu/nifi/conf/nifi.properties "nifi.remote.input.secure" "false"
prop_replace /home/ubuntu/nifi/conf/nifi.properties "nifi.cluster.is.node" "true"
prop_replace /home/ubuntu/nifi/conf/nifi.properties "nifi.cluster.node.address" "<nifi-hostname>"
prop_replace /home/ubuntu/nifi/conf/nifi.properties "nifi.cluster.node.protocol.port" "9998"
prop_replace /home/ubuntu/nifi/conf/nifi.properties "nifi.cluster.node.protocol.max.threads" "10"
prop_replace /home/ubuntu/nifi/conf/nifi.properties "nifi.cluster.flow.election.max.wait.time" "2 mins"
prop_replace /home/ubuntu/nifi/conf/nifi.properties "nifi.zookeeper.connect.string" "<zookeeper-hostname>:2181"


#Restart nifi
/home/ubuntu/nifi/bin/nifi.sh restart
