##########################################
# Input Variables
##########################################
variable "key_pair_name" {
  description = "Existing AWS EC2 key pair name"
  type        = string
  default     = "key-chinmayee-eu-west-1"
}

variable "enable_alb" {
  description = "Toggle ALB creation (keep false for single-AZ)"
  type        = bool
  default     = false
}
