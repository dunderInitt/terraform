provider "aws" {
    region =  "us-east-2"
}

variable "number_example" {
    description = "This is an example of a number in Terraform"
    type = number
    default =  42
  
}

variable "list_example" {
    description = "this is an example of a list in Terraform"
    type = list
    default = ["a","b","c"]
  
}

variable "list_numeric_example" {
    description = "a list of numbers in Terraform"
    type = list(number)
    default = [1,2,3]
}

variable "map_example" {
    description = "a map aka K/V pair in Terraform"
    type = map(string)
    default = {
        key1 = "value1"
        key2 = "value2"
        key3 = "value3"
    }
}

variable "object_example" {
    description = "an object in Terraform"
    type = object({
        name = string
        age = number
        tags = list(string)
        enabled = bool 
    })

    default = {
      name = "value1"
      age = 42
      tags = ["A","B","C"]
      enabled = true
    }
}

variable "server_port" {
    description = "the port on which the website will be bound to for http request"
    type = number
    default = 8080
}

output "public_ip" {
    description = "public ip of the web server"
    value = aws_instance.example.public_ip
  
}

resource "aws_instance" "example" {
    ami             = "ami-0fb653ca2d3203ac1"
    instance_type   = "t2.micro"
    vpc_security_group_ids = [aws_security_group.instance.id]

    user_data = <<-EOF
                #!bin/bash
                echo "This is a basic website, hello world" > index.html
                nohup busybox httpd -f -p ${var.server_port} &
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
        from_port = var.server_port
        to_port = var.server_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
  
}


