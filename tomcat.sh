#!/bin/bash
yum install java java-devel net-tools vim -y


PREFIX='/usr/local/tomcat'


## add user
useradd -U tomcat
chown -R tomcat. /usr/local/tomcat


## download and install tomcat
wget http://ftp.byfly.by/pub/apache.org/tomcat/tomcat-8/v8.5.31/bin/apache-tomcat-8.5.31.tar.gz
tar xvf apache-tomcat-8.5.31.tar.gz 
mkdir $PREFIX 
cp -r apache-tomcat-8.5.31/* $PREFIX/

## give owner tomcat to the folder
chown -R tomcat. $PREFIX


## cp unit file for comfort work with daemon
cp /vagrant/tomcat.service /etc/systemd/system/


systemctl daemon-reload
systemctl start tomcat


su - tomcat -c "cp /vagrant/TestApp.war $PREFIX/webapps/"
sleep 10
su - tomcat -c "cp -r /vagrant/lib/* $PREFIX/webapps/TestApp/WEB-INF/lib/"


if [ ! -f $PREFIX/webapps/TestApp/META-INF/context.xml  ]
then  
	su - tomcat -c 'echo "<Context allowCasualMultipartParsing=\"true\">" >> /usr/local/tomcat/webapps/TestApp/META-INF/context.xml'
	echo '</Context>' >> $PREFIX/webapps/TestApp/META-INF/context.xml 
	
fi


if [ ! -f $PREFIX/webapps/TestApp/500.jsp  ]
then
	su - tomcat -c 'echo "<h1> Im 500 error, but is opened when you catch 404</h1>" > /usr/local/tomcat/webapps/TestApp/500.jsp'
fi


grep 404  $PREFIX/webapps/TestApp/WEB-INF/web.xml 
if [ $? -ne '0'  ]
then 
	sed -i '/<\/web-app>/i <error-page>\n<error-code>404</error-code>\n<location>/500.jsp</location>\n<\/error-page>' $PREFIX/webapps/TestApp/WEB-INF/web.xml
	chown tomcat. $PREFIX/webapps/TestApp/WEB-INF/web.xml
fi


systemctl stop tomcat
systemctl start tomcat

