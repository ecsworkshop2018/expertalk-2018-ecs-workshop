[
  {
    "name": "${service_name}",
    "image": "${docker_image}",
    "memoryReservation": ${memory_reservation},
    "essential": true,
    "mountPoints": [
      {
        "containerPath": "${efs_container_path}",
        "sourceVolume": "${efs_volume_name}"
      },
      {
        "containerPath": "/var/run/docker.sock",
        "sourceVolume": "${docker_sock_volume}"
      }
    ],
    "portMappings": [
      {
        "containerPort": ${container_port}
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${log_group}",
        "awslogs-region": "${region}",
        "awslogs-stream-prefix": "${service_name}"
      }
    },
    "environment": [
      {
        "name": "JENKINS_OPTS",
        "value": "--prefix=/jenkins"
      }
    ]
  }
]
