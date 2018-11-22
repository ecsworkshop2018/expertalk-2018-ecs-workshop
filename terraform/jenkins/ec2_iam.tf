resource "aws_iam_role" "jenkins_instance_ec2" {
  name = "${local.unique}-jenkins-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ec2_service_role" {
  role       = "${aws_iam_role.jenkins_instance_ec2.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  depends_on = ["aws_iam_role.jenkins_instance_ec2"]
}

resource "aws_iam_instance_profile" "jenkins_instance_profile" {
  name       = "${aws_iam_role.jenkins_instance_ec2.name}"
  role       = "${aws_iam_role.jenkins_instance_ec2.name}"
  depends_on = ["aws_iam_role.jenkins_instance_ec2"]
}
