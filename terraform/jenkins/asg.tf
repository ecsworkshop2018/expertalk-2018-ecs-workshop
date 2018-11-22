resource "aws_autoscaling_group" "jenkins_asg" {
  name                      = "${local.unique}-jenkins-asg"
  max_size                  = 1
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  launch_configuration      = "${aws_launch_configuration.jenkins_lc.name}"
  vpc_zone_identifier       = ["${data.aws_subnet_ids.dev_vpc_public_subnet_ids.ids}"]
  default_cooldown          = 300

  enabled_metrics = [
    "GroupStandbyInstances",
    "GroupTotalInstances",
    "GroupPendingInstances",
    "GroupTerminatingInstances",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupMinSize",
    "GroupMaxSize",
  ]

  tag {
    key                 = "Name"
    value               = "${local.unique}-jenkins-ecs-asg-ec2"
    propagate_at_launch = true
  }
}

resource "null_resource" "rotate_asg_instances" {
  triggers {
    launch_configuration = "${aws_launch_configuration.jenkins_lc.id}"
  }

  depends_on = ["aws_autoscaling_group.jenkins_asg"]

  provisioner "local-exec" {
    command = "python3 ${path.module}/roll_asg_instances.py ${aws_autoscaling_group.jenkins_asg.name}"
  }
}