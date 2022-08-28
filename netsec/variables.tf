# --- net/variables.tf

variable "vpc_cidr" {
  type = string
}

variable "ext_ip" {
  type = string
}

# variable "pb_cidrs" {
#   type = list(any)
# }

variable "pt_cidrs" {
  type = list(any)
}

# variable "vpc_cidr" {
#   type = string
# }

variable "pb_cidrs" {
  type = list(any)
}

# variable "pt_cidrs" {
#   type = list(any)
# }

# variable "ext_ip" {
#   type = string
# }