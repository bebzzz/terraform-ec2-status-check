import boto3
import sys

my_region = sys.argv[1]
ec2client = boto3.client('ec2', region_name=my_region)
cloudwatch = boto3.client('cloudwatch', region_name=my_region)
account = boto3.client('sts').get_caller_identity().get('Account')

sns_topic_arn = "arn:aws:sns:" + my_region + ":" + account + ":notification_for_instance_recovery"

response = ec2client.describe_instances()
for reservation in response["Reservations"]:
    for instance in reservation["Instances"]:
        if (instance["State"]["Name"] == "running"):
            instance_id = instance["InstanceId"]

            cloudwatch.put_metric_alarm(
            AlarmName='StatusCheckFailed_Instance_' + instance_id,
            ComparisonOperator='GreaterThanThreshold',
            EvaluationPeriods=2,
            MetricName='StatusCheckFailed_Instance',
            Namespace='AWS/EC2',
            Period=60,
            Statistic='Minimum',
            Threshold=0,
            ActionsEnabled=True,
            AlarmActions=[
                'arn:aws:automate:' + my_region + ':ec2:reboot',
                sns_topic_arn
            ],
            AlarmDescription='This metric monitors EC2 Instance status check',
            Dimensions=[
                {
                  'Name': 'InstanceId',
                  'Value': instance_id
                },
            ],
            Unit='Seconds'
            )

            cloudwatch.put_metric_alarm(
            AlarmName='StatusCheckFailed_System_' + instance_id,
            ComparisonOperator='GreaterThanThreshold',
            EvaluationPeriods=2,
            MetricName='StatusCheckFailed_System',
            Namespace='AWS/EC2',
            Period=60,
            Statistic='Minimum',
            Threshold=0,
            ActionsEnabled=True,
            AlarmActions=[
                'arn:aws:automate:' + my_region + ':ec2:recover',
                sns_topic_arn
            ],
            AlarmDescription='This metric monitors EC2 System status check',
            Dimensions=[
                {
                  'Name': 'InstanceId',
                  'Value': instance_id
                },
            ],
            Unit='Seconds'
            )
