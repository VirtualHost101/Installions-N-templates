# Common YUM and RPM packages across the servers

sudo cp ./subscription-manager.conf.j2 subscription-manager.conf
sudo cp ./product-id.conf.j2 /etc/yum/pluginconf.d/product-id.conf
sudo rm -rfv /var/cache/yum/*
sudo yum clean all
sudo yum -y update
sudo yum -y install git vim java wget unzip net-tools
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

[QA- Staging]
tomcat-server:ip

[Prod-Staging]
tomcat-server:ip

