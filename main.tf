provider "aws" {
  region = "us-west-2"
}

resource "aws_key_pair" "deployer" {
  key_name   = "ec2-key"
  public_key = file("C:/Users/setia/.ssh/ec2-key.pub")
}

resource "aws_instance" "nagios_server" {
  ami           = "ami-05f991c49d264708f"  # Ubuntu 22.04 LTS in us-west-2
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name

  tags = {
    Name = "Nagios-Ubuntu"
  } 

  vpc_security_group_ids = [aws_security_group.nagios_sg.id]

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y apache2 php libapache2-mod-php build-essential unzip openssl libssl-dev",
      "sudo useradd nagios",
      "sudo groupadd nagcmd",
      "sudo usermod -a -G nagcmd nagios",
      "sudo usermod -a -G nagcmd www-data",
      "wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.5.2.tar.gz",
      "tar xzf nagios-4.5.2.tar.gz",
      "cd nagios-4.5.2 && ./configure --with-command-group=nagcmd && make all",
      "sudo make install && sudo make install-init && sudo make install-config && sudo make install-commandmode && sudo make install-webconf",
      "sudo htpasswd -cb /usr/local/nagios/etc/htpasswd.users nagiosadmin yourpassword",
      "sudo a2enmod cgi rewrite && sudo systemctl restart apache2",
      "wget https://nagios-plugins.org/download/nagios-plugins-2.4.9.tar.gz",
      "tar xzf nagios-plugins-2.4.9.tar.gz",
      "cd nagios-plugins-2.4.9 && ./configure --with-nagios-user=nagios --with-nagios-group=nagcmd && make && sudo make install",
      "sudo systemctl start nagios && sudo systemctl enable nagios"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("C:/Users/setia/.ssh/ec2-key")  # Use matching private key
      host        = self.public_ip
    }
  }
}

resource "aws_security_group" "nagios_sg" {
  name        = "nagios-sg"
  description = "Allow SSH and HTTP access"
  vpc_id = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "NagiosSecurityGroup"
  }
}

data "aws_vpc" "default" {
  default = true
}