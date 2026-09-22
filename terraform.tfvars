resource_group_name = "rg-terraform-lab4"
location            = "eastus"
environment         = "dev"

subnets = {
  web = {
    address_prefix = "10.20.1.0/24"
    tier           = "frontend"
  }

  app = {
    address_prefix = "10.20.2.0/24"
    tier           = "application"
  }

  db = {
    address_prefix = "10.20.3.0/24"
    tier           = "database"
  }
}

ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCr7Xf1fiij5Q3m9+4SqXV/bXIHUolceYLTRM64pf9bbpIA+EnddlxYu6KVG2m3UHOVWYad2hh4Q8tBUZDbEwAg4l8j0xHA3lGwSxnHI2uE7nnMySji6xIPX625v4xq/AVttk2K+nSXv4qIPK/Ki6uw6+fSYn9DTJeWHcZRjRtBlrlQmGaaqp6ck3xLuiBJTRMKHAeh83XFweRSTif4YF1xz9Ed5ZW1IKONaR0rpIBDpIN0iFcMd0onrwJbjUrFM41xfuR26RjBkLIjJ+lHD1brK63Lbx2QuCAOGkMhh75S0bTuRrIjxH+tu4kQgxmdW7Gwe7M/OowU7bDHXtajJ7vBenr75PQVyanerjU9tcgHVOWWXaVwZZQyXMTl/E59kh4S59GmHBwklXSmUZrIfJYa7e+ymrHJcSMY5ut+0cCONxoarWFsE75ZBB5t2IKh6iUMFW/dsFy3JizwWw/fXwHKpbyDbSeVtC0Qv31HifqwYCPRX5jiV8HjLvXOPan8N+TXho3FdTYTIO7bvebyoECzhUmUPszARY/dXUcZnuW7KzLFNW7/qC/x4EVU5MS5WaIO4g+qazrSjTjj9k437D2c3Q+DPyHUQczpDQ/79LSOzlFooKE3S7xVxzP0g+raVVImQdF61+AIX5UgE4Wi1+9GrB5Nxleg2lvhRHxj4y/tbQ== syedaftab04@SYEDBASIT26"
