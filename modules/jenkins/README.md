# Jenkins Terraform Module

## Overview

This module provisions a **Jenkins** server on a single **t2.micro** EC2 instance (free‑tier compatible).  It also creates:
- An IAM role with the minimal permissions required for the instance to access S3 (artifact bucket) and ECR (pull/push Docker images).
- A security group allowing inbound HTTP (8080) for the Jenkins UI and inbound SSH (22) from the current public IP (auto‑detected via a data source).
- An optional key‑pair (you can supply an existing one).

The module is intended to be referenced from each environment (dev, test, uat, prod) via the `jenkins` module directory.
