terraform {

  backend "s3" {
    region = "ap-northeast-1"

    bucket       = "fullstack-api-service-tfstate-dev"
    key          = "gha-terraform-executor.tfstate"
    use_lockfile = true
  }
}
