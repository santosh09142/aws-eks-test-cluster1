variable "eks_cluster_name" {
  description = "Cluster Name"
  type        = string
  default     = "test-cluster1"
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-west-2"

}
