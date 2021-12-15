variable "allowed_methods" {
    type=list
    default = [
            # "DELETE",
            "GET",
            "HEAD",
            "OPTIONS",
            # "PATCH",
            # "POST",
            # "PUT",
        ]
}
variable "var_albdns" {
}

variable "var_sec_albdns" {
}

# variable "var_hostnames" {}


variable wafid {
}

variable "cloudfrontlogs" {
    type = string
    default = "ghost-logs"
}

variable "var_aliases" {

}

variable "var_acm" {

}

variable "cachingdisabled" {
    type = string
    default = "658327ea-f89d-4fab-a63d-7e88639e58f6"
}

variable "cachingoptimized" {
    type = string
    default = "658327ea-f89d-4fab-a63d-7e88639e58f6"
}

variable "allviewer" {
    type = string
    default = "216adef6-5c7f-47e4-b989-5492eafa07d3"
}

variable "env" {

}