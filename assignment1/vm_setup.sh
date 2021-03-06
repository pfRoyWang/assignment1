#!/bin/bash

SYSTEM_DIR=/etc/systemd/system
NGINX_DIR=/etc/nginx

cd setup


sudo scp -i ~/.ssh/acit_admin_id_rsa -P 12022 nginx.conf admin@localhost:~
sudo scp -i ~/.ssh/acit_admin_id_rsa -P 12022 todoapp.service admin@localhost:~  

ssh -i ~/.ssh/acit_admin_id_rsa -p 12022 -t admin@localhost <<EOF
	echo "P@ssw0rd" | sudo -S yum install git -y;
	sudo yum install nodejs -y;
	sudo yum install npm -y;
	sudo yum install mongodb-server -y;
	sudo systemctl enable mongod;
	sudo systemctl start mongod;
	if grep "todoapp" /etc/passwd >/dev/null 2>&1;then
		echo "todoapp user already existed"
	else
		sudo useradd todoapp
		sudo passwd todoapp P@ssw0rd
	fi

	sudo yum install nginx -y
	sudo systemctl enable nginx
	sudo systemctl start nginx

	if [ ! -f $NGINX_DIR/nginx.service ]; then
        	sudo mv ~/nginx.conf $NGINX_DIR
	else
		sudo rm $NGINX_DIR/nginx.conf
		sudo mv ~/nginx.conf $NGINX_DIR
	fi

        if [ ! -f $SYSTEM_DIR/todoapp.service ]; then
                sudo mv ~/todoapp.service $SYSTEM_DIR
        else
                sudo rm $SYSTEM_DIR/todoapp.service
                sudo mv ~/todoapp.service $SYSTEM_DIR
        fi

	sudo chmod 755 /home/todoapp
	echo "P@ssw0rd" | sudo -S su - todoapp;
	if [ -d "/home/todoapp/ACIT4640-todo-app" ] || [ -d "/home/todoapp/app" ]; then
                echo "App folder existed, continue to execute the command"
		cd /home/todoapp/app
		sudo npm install
      	else	
		echo "Start Cloning"
		cd /home/todoapp
                sudo git clone https://github.com/timoguic/ACIT4640-todo-app.git
             	sudo mv ACIT4640-todo-app app
		cd /home/todoapp/app
		sudo npm install
        fi

	sudo systemctl restart nginx
	sudo systemctl daemon-reload
	sudo systemctl enable todoapp
	sudo systemctl start todoapp	
EOF

