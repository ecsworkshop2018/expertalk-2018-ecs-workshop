resource "aws_ecs_service" "service" {
  depends_on                         = ["module.alb"]
  name                               = "${local.service_name}"
  cluster                            = "${aws_ecs_cluster.jenkins_cluster.id}"
  task_definition                    = "${aws_ecs_task_definition.task_definition.arn}"
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  desired_count                      = 1
  health_check_grace_period_seconds  = 60

  load_balancer {
    //target_group_arn = "${aws_alb_target_group.alb_jenkins_target_group.arn}"
    target_group_arn = "${module.alb.alb_https_listener_default_tg_arn}"
    container_name   = "${local.service_name}"
    container_port   = "${local.jenkins_container_port}"
  }

  lifecycle {
    ignore_changes = ["desired_count"]
  }
}

resource "aws_ecs_task_definition" "task_definition" {
  family                = "${local.service_name}"
  container_definitions = "${data.template_file.container_definitions_json.rendered}"
  task_role_arn         = "${aws_iam_role.jenkins_task_role.arn}"

  volume {
    name      = "${local.efs_volume_name}"
    host_path = "${local.efs_host_path}"
  }

  volume {
    name      = "${local.docker_sock_volume_name}"
    host_path = "/var/run/docker.sock"
  }

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  service_name            = "jenkins"
  jenkins_log_group_name  = "jenkins_logs"
  jenkins_container_port  = 8080
  docker_sock_volume_name = "dockerSockVolume"
}

variable "jenkins_docker_image" {}

data "template_file" "container_definitions_json" {
  template = "${file("./container-definitions.json.tpl")}"

  vars {
    service_name       = "${local.service_name}"
    docker_image       = "${var.jenkins_docker_image}"
    container_port     = "${local.jenkins_container_port}"
    log_group          = "${local.jenkins_log_group_name}"
    memory_reservation = 1536
    efs_container_path = "${local.efs_host_path}"
    efs_volume_name    = "${local.efs_volume_name}"
    region             = "${local.region}"
    docker_sock_volume = "${local.docker_sock_volume_name}"
  }
}

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "${local.jenkins_log_group_name}"
  retention_in_days = 7
}

resource "aws_iam_role" "jenkins_task_role" {
  name = "jenkins-task-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource aws_iam_role_policy_attachment "jenkins_task_role_policy_attachment" {
  role       = "${aws_iam_role.jenkins_task_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}
