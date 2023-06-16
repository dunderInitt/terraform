provider "aws" {
    region =  "us-east-2"
}

resource "aws_instance" "example" {
    ami             = "ami-0fb653ca2d3203ac1"
    instance_type   = "t2.micro"
    vpc_security_group_ids = [aws_security_group.instance.id]

    user_data = <<-EOF
                #!bin/bash
                echo "This is a basic website, hello world" > index.html
                nohup busybox httpd -f -p 8080 &
                EOF
    #user data runs only on creation of VM, so needs to be re-created when we change the infra and the vm boots again.
    user_data_replace_on_change = true

    tags = {
        Name = "terraform-example"
    }
}


#create security group to allow traffic on port 8080
resource "aws_security_group" "instance" {
    name = "terraform-example-instance"

    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
  
}


