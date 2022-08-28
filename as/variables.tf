# --- as/variables.tf

variable "webserver_type" {
  type    = string
  default = "t2.micro"
}
variable "bastion_type" {
  type    = string
  default = "t2.micro"
}

variable "pb_sg" {}
variable "pt_sg" {}
variable "pt_sn" {}
variable "pb_sn" {}
variable "key" {}
variable "alb_tg" {}