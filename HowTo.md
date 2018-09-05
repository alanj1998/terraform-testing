## READ UP ON [https://blog.gruntwork.io/a-comprehensive-guide-to-terraform-b3d32832baca](How to use Terraform by Gruntwork.io)

1. Set up provider of aws :
```
provider "aws" {
  access_key = "ACCESS_KEY"
  secret_key = "SECRET_KEY"
  region     = "eu-west-1"
}
```

2. Setup Resources such as 
- Security Groups:
```
resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow http"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```
- Key Pairs:
```
resource "aws_key_pair" "my-test-key" {
  key_name   = "test-key"
  public_key = "${file("~/.ssh/terraform.test.pub")}"
}
```
- EC2 instances:
```
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
```

3. Declare Variables in vars.tf
```
variable "aws_key" {
    default = "KEY"
}
```
It allows you to declare defaults.

4. Initialize vars in seperate *.tfvars file and make sure to add that file to .gitignore