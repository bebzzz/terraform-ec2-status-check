import boto3
import os
import json

def lambda_handler(event, context):
    message = event['Records'][0]['Sns']['Message']
    parsed_message = json.loads(message)
    account = parsed_message["account"]
    my_region = parsed_message["region"]
    instance_id = parsed_message["detail"]["instance-id"]
    state = parsed_message["detail"]["state"]
    sns_topic_arn = "arn:aws:sns:" + my_region + ":" + account + ":" + os.environ['sns_topic_name']

    # Create CloudWatch client
    cloudwatch = boto3.client('cloudwatch', region_name=my_region)

    if (state == "running"):
        # Create alarm for System Status Check
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

        # Create alarm for Instance Status Check
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

    elif (state == "stopping" or state == "shutting-down" or state == "terminated"):
        # Delete alarms
        cloudwatch.delete_alarms(
            AlarmNames=['StatusCheckFailed_System_' + instance_id],
        )
        cloudwatch.delete_alarms(
            AlarmNames=['StatusCheckFailed_Instance_' + instance_id],
        )
    else:
        return
