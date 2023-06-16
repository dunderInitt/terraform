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

# output "public_ip" {
#     description = "public ip of the web server"
#     value = aws_instance.example.public_ip
# }

resource "aws_launch_configuration" "example" {
    image_id        = "ami-0fb653ca2d3203ac1"
    instance_type   = "t2.micro"
    security_groups = [aws_security_group.instance.id]

    user_data = <<-EOF
                #!bin/bash
                echo "This is a basic website, hello world" > index.html
                nohup busybox httpd -f -p ${var.server_port} &
                EOF

    #Required when using a launch config with an auto scaling group aws stuff
    lifecycle {
        #creates new instance first before destroying running config to auto scale the group (dont delete the first node if the scaling is called on)
      create_before_destroy = true
    }

}

resource "aws_autoscaling_group" "example" {
        launch_configuration = aws_launch_configuration.example.name
        vpc_zone_identifier = data.aws_subnets.default.ids

        min_size = 2
        max_size = 10

        tag {
            key         = "Name"
            value       = "terraform-asg-example"
            propagate_at_launch = true
        }
}

data "aws_vpc" "default" {
    default = true
}

data "aws_subnets" "default" {
    filter {
      name = "vpc-id"
      values = [data.aws_vpc.default.id]
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


