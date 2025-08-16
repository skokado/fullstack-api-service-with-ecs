terraform {

  backend "s3" {
    region = "ap-northeast-1"

    bucket       = "fullstack-api-service-tfstate-dev"
    key          = "application.tfstate"
    use_lockfile = true
  }
}
