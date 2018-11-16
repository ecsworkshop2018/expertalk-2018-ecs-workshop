import sys
import time
import logging
import boto3

IN_SERVICE_TIMEOUT = 600
IN_SERVICE_INTERVAL = 20

client = boto3.client('autoscaling')

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)


def describe_asg(asg_name):
    return client.describe_auto_scaling_groups(AutoScalingGroupNames=[asg_name])


def roll_instances(asg_name, describe_asg_fn=describe_asg):
    asg = get_asg(asg_name, describe_asg_fn)
    asg.roll_instances()
    return


def get_asg(asg_name, describe_asg_fn):
    logger.debug("starting instance rolling for asg: %s", asg_name)
    asg_info = describe_asg_fn(asg_name)["AutoScalingGroups"][0]
    asg = ASG(asg_name, instance_ids(asg_info), asg_info["DesiredCapacity"], asg_info["MaxSize"])
    return asg


def instance_ids(asg_info):
    return list(map(lambda instance_info: instance_info["InstanceId"], asg_info["Instances"]))


def suspend_processes(asg_name):
    logger.debug("suspending scaling processes for asg: %s", asg_name)
    client.suspend_processes(AutoScalingGroupName=asg_name, ScalingProcesses=["HealthCheck", "ReplaceUnhealthy",
                                                                              "AZRebalance", "AlarmNotification",
                                                                              "ScheduledActions"])
    return


def update_asg_desired_max(asg_name, desired, max):
    logger.debug("updating asg %s desired count to %d and max %d", asg_name, desired, max)
    client.update_auto_scaling_group(AutoScalingGroupName=asg_name, DesiredCapacity=desired, MaxSize=max)
    return


def in_service_instances(asg_name):
    asg_info = client.describe_auto_scaling_groups(AutoScalingGroupNames=[asg_name])
    instance_lifecycle_states = map(lambda instance_info : instance_info["LifecycleState"], asg_info["AutoScalingGroups"][0]["Instances"])
    number_of_in_service_instances = len([status for status in instance_lifecycle_states if status == "InService"])
    logger.debug("number of instances in service %d for Asg: %s", number_of_in_service_instances, asg_name)
    return number_of_in_service_instances


def resume_processes(asg_name):
    logger.debug("resuming scaling processes for asg: %s", asg_name)
    client.resume_processes(AutoScalingGroupName=asg_name, ScalingProcesses=["HealthCheck", "ReplaceUnhealthy",
                                                                              "AZRebalance", "AlarmNotification",
                                                                              "ScheduledActions"])
    return


def terminate_instance(instance_id, decrement_desired_capacity):
    logger.debug("terminating instance: %s", instance_id)
    client.terminate_instance_in_auto_scaling_group(InstanceId=instance_id, ShouldDecrementDesiredCapacity=decrement_desired_capacity)
    return


class ASG:
    def __init__(self, name, instances, desired, max):
        self.name = name
        self.instances = instances
        self.desired = desired
        self.max = max
        return

    def roll_instances(self, suspend_processes=suspend_processes, update_asg_desired_max=update_asg_desired_max, in_service_instances=in_service_instances, resume_processes=resume_processes, terminate_instance=terminate_instance):
        if len(self.instances) > 0:
            try:
                suspend_processes(self.name)
                update_asg_desired_max(self.name, self.desired*2, max(self.max, self.desired*2))

                x = IN_SERVICE_TIMEOUT
                while (x > 0) and (in_service_instances(self.name) < self.desired*2):
                    x -= IN_SERVICE_INTERVAL
                    time.sleep(IN_SERVICE_INTERVAL)

                if in_service_instances(self.name) < self.desired*2:
                    logger.error("TimeoutError: Enough instances did not become InService")
                    raise ValueError("TimeoutError: Enough instances did not become InService")

                for i in self.instances:
                    terminate_instance(i, True)
            finally:
                update_asg_desired_max(self.name, self.desired, self.max)
                resume_processes(self.name)
        return


if __name__ == "__main__":
    asg_name = sys.argv[1]
    roll_instances(asg_name)