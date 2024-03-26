storage "file" {
  path = "/vault/file"
}

listener "tcp" {
  address = "[::]:8200"
  tls_disable=  "true"
}

api_addr = "http://0.0.0.0:8200"
ui = true
disable_mlock = true
