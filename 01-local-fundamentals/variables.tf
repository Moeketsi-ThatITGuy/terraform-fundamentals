variable "team_name" {

  type    = string
  default = "DevOps"
}

variable "base_path" {

  type = string
}

variable "enviroments" {

  type    = set(string)
  default = ["dev", "staging", "prod"]

}

variable "team_members" {


  type    = map(any)
  default = { "moeketsi" = "engineer", "emmanuel" = "architect", "james" = "manager" }
}

variable "log_count" {

  type    = number
  default = 4
}