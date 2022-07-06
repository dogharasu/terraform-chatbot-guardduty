############################################################################
# プロバイダ設定
############################################################################
provider "aws" {
  region = "ap-northeast-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

############################################################################
# バックエンド設定
############################################################################
terraform {
  backend "s3" {
    bucket         = "＜バックエンド用S3バケット名＞"
    key            = "state/terraform.tfstate"
    encrypt        = true
    region         = "ap-northeast-1"
    dynamodb_table = "＜バックエンド用DynamonDBテーブル名＞"
  }
}
