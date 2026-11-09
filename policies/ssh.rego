package main

# Deny SSH open to 0.0.0.0/0 in any security group rule
deny[msg] {
    r := input.resource_changes[_]
    r.type == "aws_security_group"
    ing := r.change.after.ingress[_]
    ing.from_port <= 22
    ing.to_port   >= 22
    ing.cidr_blocks[_] == "0.0.0.0/0"
    msg := sprintf("SSH open to 0.0.0.0/0 in %s", [r.address])
}

deny[msg] {
    r := input.resource_changes[_]
    r.type == "aws_security_group_rule"
    r.change.after.from_port == 22
    r.change.after.cidr_blocks[_] == "0.0.0.0/0"
    msg := sprintf("SSH open to 0.0.0.0/0 in %s", [r.address])
}

# Deny unencrypted S3 buckets
deny[msg] {
    r := input.resource_changes[_]
    r.type == "aws_s3_bucket"
    not has_encryption
    msg := sprintf("S3 bucket %s has no encryption configuration", [r.address])
}

has_encryption {
    some i
    input.resource_changes[i].type == "aws_s3_bucket_server_side_encryption_configuration"
}
