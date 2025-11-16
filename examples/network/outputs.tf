### output variables

output "subnets" {
  value = {
    vpc  = module.vpc.subnets
    corp = module.corp.subnets
  }
}

output "route_tables" {
  value = {
    vpc  = module.vpc.route_tables
    corp = module.corp.route_tables
  }
}
