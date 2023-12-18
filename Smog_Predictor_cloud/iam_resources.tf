# This file defines IAM assosciated resources: IAM profiles, IAM roles.
# It also includes: S3 buckets policies.

# IAM resources for web tier

resource "aws_iam_instance_profile" "dev_web_server_iam_profile" {
    name        = "web-server-ec2-profile"
    role        = aws_iam_role.dev_web_iam_role.name
}


resource "aws_iam_role" "dev_web_iam_role" {
    name        = "dev-web-ssm-role"
    description = "The role for the developer resources EC2"
    assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": {
"Effect": "Allow",
"Principal": {"Service": "ec2.amazonaws.com"},
"Action": "sts:AssumeRole"
}
}
EOF
    tags        = {
                    Name = "dev_web_SSM"
                    }
}

resource "aws_iam_role_policy_attachment" "role_policy_atta_web" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  ])

  role       = aws_iam_role.dev_web_iam_role.name
  policy_arn = each.value
}

# IAM resources for private-compute tier

resource "aws_iam_instance_profile" "dev_training_instance_iam_profile" {
    name        = "training-instance-ec2-profile"
    role        = aws_iam_role.dev_priv_compute_iam_role.name
}

resource "aws_iam_role" "dev_priv_compute_iam_role" {
    name        = "dev-priv-compute-ssm-role"
    description = "The role for the developer resources EC2"
    assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": {
"Effect": "Allow",
"Principal": {"Service": "ec2.amazonaws.com"},
"Action": "sts:AssumeRole"
}
}
EOF
    tags        = {
                    Name = "dev_priv_compute_SSM"
                    }
}

resource "aws_iam_role_policy_attachment" "role_policy_attachment_priv_compute" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  ])

  role       = aws_iam_role.dev_priv_compute_iam_role.name
  policy_arn = each.value
}

# S3 buckets policies:
# Web Tier

resource "aws_s3_bucket_policy" "full_site_bucket_policy" {
    bucket = aws_s3_bucket.site_content_bucket.bucket

policy = jsonencode({
"Version": "2012-10-17",
"Statement": [
{
"Effect": "Allow",
"Principal": {
"AWS": ["arn:aws:iam::${local.account_id}:role/${aws_iam_role.dev_web_iam_role.name}"]
},
"Action": [
"s3:DeleteObject",
"s3:PutObject",
"s3:GetObject",
"s3:ListBucket",
],
"Resource": [
"arn:aws:s3:::${aws_s3_bucket.site_content_bucket.bucket}",
"arn:aws:s3:::${aws_s3_bucket.site_content_bucket.bucket}/*"
]
}
]
})
}

resource "aws_s3_bucket_policy" "read_write_plotter_bucket_policy" {
    bucket = aws_s3_bucket.smog_plotter_bucket.bucket

policy = jsonencode({
"Version": "2012-10-17",
"Statement": [
{
"Effect": "Allow",
"Principal": {
"AWS": ["arn:aws:iam::${local.account_id}:role/${aws_iam_role.dev_web_iam_role.name}"]
},
"Action": [
"s3:GetObject",
"s3:ListBucket",
],
"Resource": [
"arn:aws:s3:::${aws_s3_bucket.smog_plotter_bucket.bucket}",
"arn:aws:s3:::${aws_s3_bucket.smog_plotter_bucket.bucket}/*"
]
},
{
"Effect": "Allow",
"Principal": {
"AWS": ["arn:aws:iam::${local.account_id}:role/${aws_iam_role.dev_priv_compute_iam_role.name}"]
},
"Action": [
"s3:PutObject",
"s3:ListBucket"
],
"Resource": [
"arn:aws:s3:::${aws_s3_bucket.smog_plotter_bucket.bucket}",
"arn:aws:s3:::${aws_s3_bucket.smog_plotter_bucket.bucket}/*"
]
}
]
})
}

# Private-compute Tier

resource "aws_s3_bucket_policy" "read_data_bucket_policy" {
    bucket = aws_s3_bucket.smog_data_bucket.bucket

policy = jsonencode({
"Version": "2012-10-17",
"Statement": [
{
"Effect": "Allow",
"Principal": {
"AWS": ["arn:aws:iam::${local.account_id}:role/${aws_iam_role.dev_priv_compute_iam_role.name}"]
},
"Action": [
"s3:GetObject",
"s3:ListBucket",
],
"Resource": [
"arn:aws:s3:::${aws_s3_bucket.smog_data_bucket.bucket}",
"arn:aws:s3:::${aws_s3_bucket.smog_data_bucket.bucket}/*"
]
},

]
})
}

resource "aws_s3_bucket_policy" "full_model_bucket_policy" {
    bucket = aws_s3_bucket.smog_model_bucket.bucket

policy = jsonencode({
"Version": "2012-10-17",
"Statement": [
{
"Effect": "Allow",
"Principal": {
"AWS": ["arn:aws:iam::${local.account_id}:role/${aws_iam_role.dev_priv_compute_iam_role.name}"]
},
"Action": [
"s3:DeleteObject",
"s3:PutObject",
"s3:GetObject",
"s3:ListBucket",
],
"Resource": [
"arn:aws:s3:::${aws_s3_bucket.smog_model_bucket.bucket}",
"arn:aws:s3:::${aws_s3_bucket.smog_model_bucket.bucket}/*"
]
}
]
})
}