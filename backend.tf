terraform {
  backend "s3" {
    bucket         = "terraformstatefiles-us-west-2"
    key            = "test-eks-cluster1/test-cluster-terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"

    profile = "default"
  }
}

// ...existing code...
