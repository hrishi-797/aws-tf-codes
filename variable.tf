variable "vpc_cidr" {
    type = string
    default = "10.0.0.0/16"
  
}

variable "dmz_subnet_cidrs" {
    type = list(string)
    default = ["10.0.0.0/24","10.0.1.0/24","10.0.2.0/24"]
  
}

variable "web_subnet_cidrs" {
    type = list(string)
    default = ["10.0.3.0/24","10.0.4.0/24","10.0.5.0/24"]
  
}

variable "app_subnet_cidrs" {
    type = list(string)
    default = ["10.0.6.0/24", "10.0.7.0/24", "10.0.8.0/24"]
  
}

variable "db_subnet_cidrs" {
    type = list(string)
    default = ["10.0.9.0/24", "10.0.10.0/24", "10.0.11.0/24"]
  
}

variable "region" {
    type = string
    default = "us-east-1a"
  
}