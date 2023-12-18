#S3 buckets

resource "aws_s3_bucket" "smog_data_bucket" {
    bucket = "smog-data-bucket"
    tags = {
            Name = "smog_data_bucket"
    }
}

resource "aws_s3_bucket" "smog_plotter_bucket" {
    bucket = "smog-plotter-bucket"
    tags = {
            Name = "smog_plotter_bucket"
    }
}

resource "aws_s3_bucket" "smog_model_bucket" {
    bucket = "smog-model-bucket"
    tags = {
            Name = "smog-model-bucket"
    }
}

resource "aws_s3_bucket" "site_content_bucket" {
    bucket = "site-content-bucket"
    tags = {
            Name = "site-content-bucket"
    }
}