# Introducton
This Terraform script is configured for AWS. It will spin up an EC2 instance and install a Nagios server.


# Prior Running Terraform.
1. Create key pair and change the name of the key in Terraform. replace ec2-key with your own key pair name and replace ec2-key.pub with your public key file.
```
resource "aws_key_pair" "deployer" {
  key_name   = "ec2-key"
  public_key = file("C:/Users/setia/.ssh/ec2-key.pub")
}
```
2. Find anothe ec2-key and replace it with your private key filename.

```
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("C:/Users/setia/.ssh/ec2-key")  # Use matching private key
      host        = self.public_ip
    }
```
3. Change Nagios password.
Find yourpassword in main.tf and replace with your own password for nagiosadmin user.
```
...
"sudo htpasswd -cb /usr/local/nagios/etc/htpasswd.users nagiosadmin yourpassword",
...
```

# Run Terraform
Execute Terraform. Run below script one at the time. If you hit error running terraform plan, try to fix it prior running 'terraform apply'
```
terraform init
terraform plan
terraform apply
```
Once EC2 is created you should see the public key. Use it to test the connection using SSH or open browser to point to the new server create. This is the URL you can access http>//<public-ip>/nagios


# Destroy EC2
As you might need to pay when EC instance is on eventhought your ec2 is free tier. This is due to the VPC that is chargeable.
```
terraform destroy
```


# Connecting to AWS EC2

```
ssh -i "C:\Users\setia\.ssh\ec2-key" ubuntu@<public IP>
```

# Checking Ubuntu version

```
lsb_release -a
```

You should see similar output below.
```
ubuntu@ip-172-31-34-146:~$ lsb_release -a
No LSB modules are available.
Distributor ID: Ubuntu
Description:    Ubuntu 24.04.2 LTS
Release:        24.04
Codename:       noble
```

# Checking Nagios Version
```
>sudo /usr/local/nagios/bin/nagios --version
Nagios Core 4.5.2
Copyright (c) 2009-present Nagios Core Development Team and Community Contributors
Copyright (c) 1999-2009 Ethan Galstad
Last Modified: 2024-04-30
License: GPL
```
