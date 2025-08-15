terraform {

  backend "s3" {
    region = "ap-northeast-1"

    bucket       = "fullstack-api-service-tfstate-dev"
    key          = "network.tfstate"
    use_lockfile = true
  }
}
