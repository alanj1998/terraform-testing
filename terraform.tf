provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow http"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_all_outband" {
  name = "allow_all_outband"
  description = "Allow all outband"

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_key_pair" "my-test-key" {
  key_name   = "test-key"
  public_key = "${file("~/.ssh/terraform.test.pub")}"
}


resource "aws_instance" "example" {
  ami           = "${var.ami}"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.my-test-key.key_name}"

  security_groups= [
    "${aws_security_group.allow_http.name}",
    "${aws_security_group.allow_all_outband.name}"
  ]

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install nginx -y",
      "sudo ufw allow 'Nginx HTTP'",
      "sudo service nginx start"
    ]

    connection {
      type          = "ssh"
      user          = "ubuntu"
      private_key   = "${file("~/.ssh/terraform.test")}"
    }
  }

  tags {
    Name = "test-instance"
  }
  
  provisioner "local-exec" {
    command = "echo ${aws_instance.example.public_ip} > ip.txt"
  }
}