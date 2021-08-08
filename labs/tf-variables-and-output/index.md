# Terraform Lab 1

## Overview 
In this lab you will:
- Create a working directory
- Install Terraform
- Clone the lab repository
- Update an existing `main.tf` file to use variables. 

## Install Terraform 
Create and enter the working directory:
```sh
mkdir -p $HOME/$(date +%Y%m%d)/terraform
cd $_
```
The AWS CloudShell does not have the latest version of Terraform installed. To install it run the following: 
```sh
TER_VER=`curl -s https://api.github.com/repos/hashicorp/terraform/releases/latest | grep tag_name | cut -d: -f2 | tr -d \"\,\v | awk '{$1=$1};1'`
wget https://releases.hashicorp.com/terraform/${TER_VER}/terraform_${TER_VER}_linux_amd64.zip
unzip terraform_${TER_VER}_linux_amd64.zip && sudo cp terraform /usr/local/bin/
```

Confirm installation was successful
```sh
terraform version 
```

Output should be similar to: `Terraform v1.0.4`


## Clone the lab repository
Use `git` to clone the lab repository to CloudShell
```
git clone https://github.com/jruels/tf-reusable-code.git
```


## Set the instance name with a variable
Under our working directory create a `tf-lab1` directory and copy `main.tf` to our new directory: 
```sh
mkdir tf-lab1 
cd $_
cp ../tf-reusable-code/labs/tf-variables-and-output/config/main.tf main.tf
```

The configuration in `main.tf` includes hard-coded values. Terraform variables allow you to write configuration that is easier to re-use and flexible. 

Add a variable to define the instance name. 

Create a new file called `variables.tf` with a block that defines a new `instance_name` variable. 

```hcl
variable "instance_name" {
  description    = "Name tag for EC2 instance"
  type           = string
  default        = "Lab1-TF-example"
}
```

Now update the `main.tf` `aws_instance` resource block to use our new variable. 

```
  tags = {
    Name = var.instance_name
  }
```

We also need to update the resource name in `main.tf` to `lab1-tf-example`
```
..snip
resource "aws_instance" "lab1-tf-example" {
  ami           = "ami-830c94e3"
  ..snip
}
```

## Initialize the directory
Now that we have our configuration file created we need to download all of the required providers and modules.
```sh
terraform init
```

Terraform uses a plugin-based architecture to support hundreds of infrastructure and service providers. Subsequent commands will use local settings and data during initialization.

## Format and validate configuration
Terraform includes a `fmt` argument to ensure consistent formatting in files and modules written by different teams. It automatically updates configurations for easy readability and consistency.

The `main.tf` file created is very basic, and is already formatted.
```sh
terraform fmt
```

If there were any formatting issues, like equal signs not aligned or wrong indentation `fmt` will fix them.

If any files are formatted Terraform will output the name of the file. If there are not formatting changes there is not output.

Now use the built-in `terraform validate` command to check and report any errors in modules, attribute names, and value types.

## Create infrastructure
Now that the provider is downloaded, configuration files are formatted and validated it's time to create the infrastructure.

Run `terraform plan` to review the changes Terraform will make.

This output shows the execution plan, describing which actions Terraform will take in order to change real infrastructure to match the configuration.

Run `terraform apply`

The output has a + next to `aws_instance.lab1-tf-example`, meaning that Terraform will create this resource. Beneath that, it shows the attributes that will be set. When the value   displayed is (known after apply), it means that the value won't be known until the resource is created.

Terraform will now pause and wait for your approval before proceeding. If anything in the plan seems incorrect or dangerous, it is safe to abort here with no changes made to your    infrastructure.

In this case the plan is acceptable, so type `yes` at the confirmation prompt to proceed. Executing the plan will take a few minutes since Terraform waits for the EC2 instance to    become available.

The instance is created using the variables provided. 

Now apply the configuration again, but pass the variable on the command-line. 
```sh
terraform apply -var 'instance_name=SomeOtherName'
```

Variables passed via the command-line will not be saved , so you need to repeatedly set them, or add them to a variables file.

## Query Data with Outputs
In this lab you will use output values to organize data to be queried and shown back to the user. 

Create a file called `outputs.tf` to output the instance's ID and Public IP address with the following: 
```hcl
output "instance_id" {
  description    = "ID of the EC2 instance"
  value          = aws_instance.lab1-tf-example.id
}

output "instance_public_ip" {
  description   = "Public IP address of EC2 instance"
  value       = aws_instance.lab1-tf-example.public_ip
}
```

## Inspect output values
You must apply the new configuration before you can use these output values. 

Apply the configuration using `terraform apply`

Terraform now prints output values to the screen every time you apply your configuration. Query the outputs using the `terraform output` command. 

Output will be similar to: 
```
instance_id = "i-0bf954919ed765de1"
instance_public_ip = "54.186.202.254"
```

You can use Terraform outputs to connect Terraform projects with other parts of your infrastructure or CICD pipelines. 

