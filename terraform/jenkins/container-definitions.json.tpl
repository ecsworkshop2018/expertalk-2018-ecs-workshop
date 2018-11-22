[
  {
    "name": "${service_name}",
    "image": "${docker_image}",
    "memory": ${memory},
    "cpu": ${cpu},
    "essential": true,
    "mountPoints": [
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
    }
  }
]
