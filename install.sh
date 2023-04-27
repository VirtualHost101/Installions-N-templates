# Common YUM and RPM packages across the servers

sudo cp ./subscription-manager.conf.j2 /etc/yum/pluginconf.d/subscription-manager.conf
sudo cp ./product-id.conf.j2 /etc/yum/pluginconf.d/product-id.conf
sudo rm -rfv /var/cache/yum/*
sudo yum clean all
sudo yum -y update
sudo yum -y install git vim wget unzip net-tools java-1.8.0-openjdk.x86_64
# -- > END < -- #


[Build]
maven-build-server:ip

sudo yum -y install maven

[Test]
sonarqube-server:ip
## Installing PostgreSQL 14 Database for SonarQube
sudo yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
sudo yum -qy module disable postgresql
sudo yum -y install postgresql14 postgresql14-server
sudo /usr/pgsql-14/bin/postgresql-14-setup initdb
sudo systemctl enable --now postgresql-14
sudo passwd postgres  ==> {{" SET NEW PASSWORD "}}
sudo su - postgres
createuser sonar
psql
ALTER USER sonar WITH ENCRYPTED password 'sonar';
CREATE DATABASE sonarqube OWNER sonar;
GRANT ALL PRIVILEGES ON DATABASE sonarqube to sonar; 
\q
exit
# Creating Sonar Qube User's and Password
sudo useradd sonar
sudo passwd sonar  ==> {{" SET NEW PASSWORD "}}

# Installing SonarQube
cd /opt
sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.1.0.47736.zip
sudo unzip sonarqube-9.1.0.47736.zip
sudo mv sonarqube-9.1.0.47736 sonarqube
sudo groupadd sonar
sudo chown -R sonar:sonar /opt/sonarqube
copy ./templates/sonar.properties.j2 /opt/sonarqube/conf/sonar.properties
copy ./templates/sonar.sh /opt/sonarqube/bin/linux-x86-64/sonar.sh
sudo systemctl daemon-reload
sudo systemctl enable --now sonar
sudo systemctl status sonar


[Binary-repo-server]
nexus-server:ip

cd /opt
sudo wget http://download.sonatype.com/nexus/3/nexus-3.23.0-03-unix.tar.gz
sudo tar -xvf nexus-3.23.0-03-unix.tar.gz
sudo mv nexus-3.23.0-03 nexus
sudo adduser nexus
sudo chown -R nexus:nexus /opt/nexus
sudo chown -R nexus:nexus /opt/sonatype-work
cp ./templates/nexus.rc.j2 /opt/nexus/bin/nexus.rc
cp ./templates/nexus.vmoptions.j2 /opt/nexus/bin/nexus.vmoptions
cp ./templates/nexus.service.j2 /etc/systemd/system/nexus.service
sudo ln -s /opt/nexus/bin/nexus /etc/init.d/nexus
sudo chkconfig --add nexus
sudo chkconfig --levels 345 nexus on
sudo service nexus start

[QA- Staging] && [Prod-Staging]
tomcat-server:ip

wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.74/bin/apache-tomcat-9.0.74.tar.gz
tar -xvf <file name>
mv <file name> tomcat
cp tomcat-host-manager-context.xml.j2 /tomcat/webapps/host-manager/META-INF/context.xml (to give access to IPs)
cp tomcat-manager-context.xml.j2 /tomcat/webapps/manager/META-INF/context.xml (to give access to IPs)
cp tomcat-server.xml.j2 /tomcat/config/sever.xml (to change port number)
cp tomcat-users.xml.j2 /tomcat/config/tomcat-users.xml (add tomcat roles, users and passwords to grant access)
cd /bin/
sh startup.sh
localhost:8080

