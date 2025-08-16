## application

ECS クラスター/サービス、ALB, ACM などWebサービスのデプロイ設定

最初に ECR を作成してイメージをプッシュする

```sh
cd terraform/application/envs/dev
terraform init
terraform apply -target module.this.module.ecr_app
```
