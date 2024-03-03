locals {
  account_id               = data.aws_caller_identity.current.account_id
  region                   = "us-east-1"
  prefix                   = "proof-concept"
  vpc_cidr                 = "10.0.0.0/24"                      #256 addresses
  vpc_subnets_cidr_public  = ["10.0.0.0/26", "10.0.0.64/26"]    #64 addresses each
  vpc_subnets_cidr_private = ["10.0.0.128/26", "10.0.0.192/26"] #64 addresses each
  vpc_availability_zones   = ["us-east-1a", "us-east-1b"]
}
