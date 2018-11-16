import pytest

from roll_asg_instances import ASG
import roll_asg_instances

roll_asg_instances.IN_SERVICE_TIMEOUT = 2
roll_asg_instances.IN_SERVICE_INTERVAL = 1


def test_should_not_suspend_scaling_processes_for_zero_instance_asg():
    processes_suspended = [False]

    def suspend_processes(asg_name):
        assert asg_name == "asg"
        processes_suspended[0] = True

    # Given
    asg = ASG("asg", [], 0, 5)
    asg.roll_instances(suspend_processes, dummy_update_asg_desired_max, dummy_in_service_instances, dummy_resume_processes, dummy_terminate_instance)
    assert processes_suspended[0] == False


def test_should_suspend_scaling_processes_before_instance_rotation():
    processes_suspended = [False]

    def suspend_processes(asg_name):
        assert asg_name == "asg"
        processes_suspended[0] = True

    # Given
    asg = ASG("asg", ["i-4ba0837f"], 1, 5)
    asg.roll_instances(suspend_processes, dummy_update_asg_desired_max, dummy_in_service_instances, dummy_resume_processes, dummy_terminate_instance)
    assert processes_suspended[0]


def test_should_double_number_of_instances():
    number_of_calls = [0]

    def update_asg(asg_name, desired, max):
        if number_of_calls[0] == 0:
            assert asg_name == "asg"
            assert desired == 2
            assert max == 5
        number_of_calls[0] += 1

    asg = ASG("asg", ["i-4ba0837f"], 1, 5)
    asg.roll_instances(dummy_suspend_processes, update_asg_desired_max=update_asg,
                       in_service_instances=dummy_in_service_instances, resume_processes=dummy_resume_processes, terminate_instance=dummy_terminate_instance)


def test_should_fail_if_instances_does_not_become_healthy_for_given_time():
    asg = ASG("asg", ["i-4ba0837f"], 1, 5)
    with pytest.raises(ValueError):
        asg.roll_instances(dummy_suspend_processes, dummy_update_asg_desired_max, timeout_in_service_instances, resume_processes=dummy_resume_processes)


def test_should_resume_processes_before_in_service_timeout():
    processes_resumed = [False]

    def resume_processes(asg_name):
        processes_resumed[0] = True

    def resume_processes(asg_name):
        processes_resumed[0] = True

    asg = ASG("asg", ["i-4ba0837f"], 1, 5)
    with pytest.raises(ValueError):
        asg.roll_instances(dummy_suspend_processes, dummy_update_asg_desired_max, timeout_in_service_instances,
                           resume_processes)
    assert processes_resumed[0]


def test_should_terminate_old_instances():
    number_of_times_called = [0]

    def terminate_instance(instance_id, decrement_desired_capacity):
        assert instance_id == "i-4ba0837f"
        assert decrement_desired_capacity
        number_of_times_called[0] += 1

    asg = ASG("asg", ["i-4ba0837f"], 1, 5)
    asg.roll_instances(dummy_suspend_processes, dummy_update_asg_desired_max, dummy_in_service_instances,
                       dummy_resume_processes, terminate_instance)
    assert number_of_times_called[0] == 1


def test_reset_desired_capacity_and_max_capacity():
    number_of_calls = [0]

    def update_asg(asg_name, desired, max):
        if number_of_calls[0] == 1:
            assert asg_name == "asg"
            assert desired == 1
            assert max == 5
        number_of_calls[0] += 1

    asg = ASG("asg", ["i-4ba0837f"], 1, 5)
    asg.roll_instances(dummy_suspend_processes, update_asg, dummy_in_service_instances,
                       dummy_resume_processes, dummy_terminate_instance)
    assert number_of_calls[0] == 2


def test_resume_services_after_instance_rolling():
    processes_resumed = [False]

    def resume_processes(asg_name):
        processes_resumed[0] = True

    asg = ASG("asg", ["i-4ba0837f"], 1, 5)
    asg.roll_instances(dummy_suspend_processes, dummy_update_asg_desired_max, dummy_in_service_instances,
                       resume_processes, dummy_terminate_instance)
    assert processes_resumed[0]


def dummy_suspend_processes(asg_name):
    return


def dummy_update_asg_desired_max(asg_name, desired, max):
    return


def dummy_in_service_instances(asg_name):
    return 2


def dummy_resume_processes(asg_name):
    return


def timeout_in_service_instances(asg_name):
    return 1


def dummy_terminate_instance(instance_id, decrease_desired_capacity):
    return
