provider "aws" {
  region           = "ap-south-1"
  access_key       = "AKIASYUFT4SJALBZFVVD"        #for security purpose i have added incorrect key 
  secret_key       = "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"  #for security purpose i have added incorrect key 
  
}

resource "aws_security_group" "mysecurity" {
  name        = "mysecurity"
  description = "Allow TLS inbound traffic"
  vpc_id      = "vpc-c7e4f9af"

  ingress {
    description = "TLS from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

 

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "MySecurityGroup"
  }
}

resource "aws_instance" "web" {
  ami           = "ami-052c08d70def0ac62"
  instance_type = "t2.micro"
  key_name = "hadoopKey"
  security_groups = ["sg-00958f01bef689d16"]
  subnet_id = "subnet-091e7545" 

  tags = {
    Name = "master"
  }
}

resource "aws_ebs_volume" "v1" {
  availability_zone = "ap-south-1b"
  size              =  10
  
  tags = {
    Name = "master_vol"
  }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.v1.id}"
  instance_id = "${aws_instance.web.id}"
  force_detach = true
}


resource "null_resource" "nullremote3"  {

depends_on = [
    aws_volume_attachment.ebs_att,
  ]


  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/ANSHIKA SHARMA/Downloads/hadoopKey.pem")
    host     = aws_instance.web.public_ip
  }

provisioner "remote-exec" {
    inline = [
      "sudo yum install git -y",
      "curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.rpm.sh | sudo bash",
      "sudo yum install git-lfs  -y",
      "sudo git lfs install",
      "sudo git-lfs clone https://github.com/Anshika-Sharma-as/hadoopClusterhadoop.git  /hdfs",
      "cd  /hdfs",
      "sudo mv jdk-8u171-linux-x64.rpm  /home/ec2-user",
      "cd",
      "sudo rm -rf /hdfs",
      "sudo git-lfs clone https://github.com/Anshika-Sharma-as/hadoopCluster.git  /hdfs",
      "cd  /hdfs",
      "sudo mv hadoop-1.2.1-1.x86_64.rpm  /home/ec2-user",
      "cd",
      "sudo rm -rf /hdfs",
      "cd /home/ec2-user",
      "sudo rpm -ivf jdk-8u171-linux-x64.rpm",
      "sudo rpm -ivh hadoop-1.2.1-1.x86_64.rpm --force",
      "cd",
      "sudo mkdir /nn",
      "cd /etc/hadoop",
      "sudo rm -rf hdfs-site.xml core-site.xml",
      "cd",
      "sudo git clone https://github.com/Anshika-Sharma-as/hadoop01.git  /hdfs",
      "cd /hdfs",
      "sudo mv hdfs-site.xml core-site.xml /etc/hadoop",
      "sudo hadoop namenode -format -force",
      "sudo hadoop-daemon.sh start namenode",
     
    ]
  }
}



resource "null_resource" "nulllocal1"  {


depends_on = [
    null_resource.nullremote3,
  ]

	provisioner "local-exec" {
	    command = "start chrome  ${aws_instance.web.public_ip}:50070"
  	}
  }
