resource "aws_instance" "project111" {
  ami           = "ami-0f5ee92e2d63afc18" 
  instance_type = "t2.micro"
   key_name               = "ka-key"
  iam_instance_profile = aws_iam_instance_profile.some_profile.name
  associate_public_ip_address = true

    user_data = <<-EOF
#!/bin/bash
       set -x
       sudo apt-get update -y
       sudo apt-get install awscli -y
       sudo apt install awscli
       aws s3 cp s3://point-loop/index.html /home/ubuntu
       aws s3 cp s3://point-loop/main.css  /home/ubuntu
       aws s3 cp s3://point-loop/favicon.ico  /home/ubuntu
       aws s3 cp s3://point-loop/main.js  /home/ubuntu
     
       EOF

}


resource "aws_iam_policy" "bucket_policy" {
  name        = "aws_s3_access_policy-0-summafun"
  path        = "/"
  description = "Allow "

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ],
        "Resource" : [
          "arn:aws:s3:::*/*",
          "arn:aws:s3:::point-loop"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "ec2_role" {
  name = "aws_s3_access_role-0-summafun"

  assume_role_policy = jsonencode({ 

    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "some_bucket_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.bucket_policy.arn
}


resource "aws_iam_instance_profile" "some_profile" {
  name = "aws_s3_profile_0_new-1-0"
  role =  aws_iam_role.ec2_role.name
}
