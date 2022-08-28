# ---- root/main.tf

module "netsec" {
  source   = "./netsec"
  vpc_cidr = "10.0.0.0/16"
  ext_ip   = "0.0.0.0/0"
  pb_cidrs = ["10.0.7.0/24", "10.0.9.0/24", "10.0.11.0/24"]
  pt_cidrs = ["10.0.8.0/24", "10.0.10.0/24", "10.0.12.0/24"]
}

module "as" {
  source = "./as"
  pb_sg  = module.netsec.pb_sg
  pt_sg  = module.netsec.pt_sg
  pt_sn  = module.netsec.pt_sn
  pb_sn  = module.netsec.pb_sn
  alb_tg = module.lb.alb_tg
  key    = "TTPKey"
}

module "lb" {
  source = "./lb"
  pb_sn  = module.netsec.pb_sn
  vpc_id = module.netsec.vpc_id
  web_sg = module.netsec.web_sg
}

# module "sec" {
#   source        = "./sec"
#   public_subnet = module.netsec.public_subnet
#   vpc_id        = module.netsec.vpc_id
#   web_sg        = module.netssec.web_sg

# }

#  3tp_alb_tg    = module.lb.alb_tg
#  key_name = 3TP
# public_subnet = module.netsec.public_subnet
# vpc_id        = module.netsec.vpc_id
# web_sg        = module.netsec.web_sg
