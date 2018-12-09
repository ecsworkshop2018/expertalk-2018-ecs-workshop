import sys
import os
import boto3
from functools import reduce
import subprocess

client = boto3.client('s3')
print_enable = False

class BucketList:

    def __init__(self, bucket_list):
        self.bucket_list = bucket_list

    def print_contents(self):
        print(self.bucket_list)
        return self

    def get_bucket_files(self):
        return BucketFiles(reduce(lambda acc, bucket: acc + get_bucket_file_map_entries(bucket), self.bucket_list, []))


class BucketFiles:

    def __init__(self, bucket_files):
        self.bucket_files = bucket_files

    def print_contents(self):
        if(print_enable):
            print("=============================================")
            print(self.bucket_files)
        return self

    def re_order_as(self, state_files_order):
        ordered_list = reduce(lambda acc, file_substr: acc + self.entries_with_substr(file_substr), state_files_order, [])
        return BucketFiles(ordered_list)

    def plan_destroy_infrastructure(self):
        for state_entry in self.bucket_files:
            print("================ Destroying state: {}/{} ===================".format(state_entry["bucket"], state_entry["state"]))
            subprocess.check_call("terraform init -reconfigure -backend-config=\"bucket={}\" -backend-config=\"key={}\""
                      .format(state_entry["bucket"], state_entry["state"]), shell=True)
            subprocess.check_call("terraform destroy -auto-approve", shell=True)
            s3 = boto3.resource('s3')
            s3.Bucket(state_entry["bucket"]).download_file(state_entry["state"], "./state_backup/" + state_entry["state"])
            s3.Object(state_entry["bucket"], state_entry["state"]).delete()
        return None

    def entries_with_substr(self, state_file_substr):
        return list(filter(lambda state_entry: state_file_substr in state_entry["state"], self.bucket_files))


def get_bucket_file_map_entries(bucket):
    response = client.list_objects_v2(Bucket=bucket)
    if "Contents" in response:
        bucket_contents = response["Contents"]
        print("bucket contains: " + str(list(map(lambda x: x["Key"], bucket_contents))))
        return list(map(lambda content: {"bucket": bucket, "state": content["Key"]}, bucket_contents))
    else:
        return []


def buckets():
    bucket_list = list(map(lambda bucket_entry: bucket_entry["Name"], client.list_buckets()["Buckets"]))
    return BucketList(bucket_list)


def destroy_terraform_infrastructure(state_files_order):
    buckets().print_contents().get_bucket_files().print_contents().re_order_as(state_files_order).print_contents() \
        .plan_destroy_infrastructure()
    return None


if __name__ == "__main__":
    states_to_destroy_in_order = ["asgard-cluster.tfstate", "dev-elb-with-dns.tfstate", "thor-service-dev.tfstate",
                                  "alb-dev.tfstate", "odin-service-dev.tfstate",
                                  "cluster-test-nginx.tfstate", "cluster-dev.tfstate", "dev-cluster.tfstate" , "jenkins.tfstate",
                                  "cluster-draining-lambda-dev.tfstate", "cluster-draining-lambda-prod.json", "cluster-draining-lambda-prod.tfstate",
                                  "cluster-scaling-lambda-dev.tfstate", "acm-certificate.tfstate", "dev-vpc-subnets-and-network.tfstate"]
    destroy_terraform_infrastructure(states_to_destroy_in_order)
