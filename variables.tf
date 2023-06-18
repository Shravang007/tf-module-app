variable "env" {}
variable "component" {}


env = "dev"


components = {

  frontend  = {}
  mongodb   = {}
  catalogue = {}
  redis     = {}
  user      = {}
  cart      = {}
  mysql     = {}
  shipping  = {}
  rabbitmq  = {}
  payment   = {}

}