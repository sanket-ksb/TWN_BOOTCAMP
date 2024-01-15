import boto3
import schedule
import requests
import smtplib
import os
import paramiko
import time
from datetime import datetime, timezone

ec2_client = boto3.client('ec2', region_name="eu-central-1")
ec2_resource = boto3.resource('ec2', region_name="eu-central-1")
#EMAIL_ADDRESS = os.environ.get('EMAIL_ADDRESS')
#EMAIL_PASSWORD = os.environ.get('EMAIL_PASSWORD')
# Dictionary to track instance start times
instance_start_times = {}

def get_instance_start_time(instance_id):
    response = ec2_client.describe_instances(InstanceIds=[instance_id])
    if 'Reservations' in response:
        reservation = response['Reservations'][0]
        if 'Instances' in reservation:
            instance = reservation['Instances'][0]
            start_time = instance.get('LaunchTime')
            return start_time
    return None

def get_instance_public_ip(instance_id):
    response = ec2_client.describe_instances(InstanceIds=[instance_id])
    if 'Reservations' in response:
        reservation = response['Reservations'][0]
        if 'Instances' in reservation:
            instance = reservation['Instances'][0]
            public_ip = instance.get('PublicIpAddress')
            return public_ip
    return "-"

def get_instance_state(instance_id):
    response = ec2_client.describe_instances(InstanceIds=[instance_id])
    if 'Reservations' in response:
        reservation = response['Reservations'][0]
        if 'Instances' in reservation:
            instance = reservation['Instances'][0]
            state = instance.get('State', {}).get('Name')  # Correctly access 'State'
            return state
    return "-"


def check_instance_status():
    instances = ec2_resource.instances.filter(
        Filters=[
            {'Name': 'tag:Environment', 'Values': ['bootcamp-demo']},
            {'Name': 'instance-state-name', 'Values': ['running','pending']},
           
        ]
    )
    for instance in instances:
        instance_id = instance.id
        public_ip = get_instance_public_ip(instance_id)
        state = get_instance_state(instance_id)
        print(f"Instance {instance_id} Public IP: {public_ip} State: {state}")
              
        if public_ip != "-" and state == "running":
            if instance_id not in instance_start_times:
                instance_start_times[instance_id] = get_instance_start_time(instance_id)
            print(f"Checking if web app is running.")
           # monitor_application(public_ip, instance_id)
    #print(instances[0][0])
    if len(list(instances)) == 0:
        print("No Instance found in running or pending state\n")
    print("---------------------------------------------------------\n")


    
def send_notification(email_msg):
    print(f"Sending an email with msg {email_msg} ...")
#    with smtplib.SMTP('smtp.gmail.com', 587) as smtp:
#        smtp.starttls()
#        smtp.ehlo()
#        smtp.login(EMAIL_ADDRESS, EMAIL_PASSWORD)
#        message = f"Subject: SITE DOWN\n{email_msg}"
#        smtp.sendmail(EMAIL_ADDRESS, EMAIL_ADDRESS, message)

def restart_app(host,username):
    print('Restarting application...')
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(hostname= host , username= username , key_filename='test.pem')
    stdin, stdout, stderr = ssh.exec_command("cd /var/www/html/ && sudo rm -r * && sudo git clone https://github.com/olesiakissa/space-tourism-website.git && sudo mv space-tourism-website/* . && echo done")
    print(stdout.readlines())
    ssh.close()
    time.sleep(5)
def try_accessing_app(host,times):
    
        for time in range(0,times):   
            try: 
                response = requests.get(f"http://{host}/")
                if response.status_code == 200:
                    return True
            except Exception as ex:
                print("application still not accessible..")
                continue
        return False

def monitor_application(host, instance_id):
    global instance_start_times

    try:
        response = requests.get(f"http://{host}/")
        if response.status_code == 200:
            print('Application is running Normally!')
           
        else:
            print('Application Down. Fixing it!')
            msg = f'Application returned {response.status_code}'
            send_notification(msg)
            restart_app(host, "ubuntu")
    except Exception as ex:
        print(f'Connection error happened: {ex}')
        msg = 'Application not accessible at all retrying 3 times...'
        if try_accessing_app(host,3):
            print("application back live again..")
            return
        else:
            if instance_id in instance_start_times:
                    start_time = instance_start_times[instance_id]
                    current_uptime = (datetime.now(timezone.utc) - start_time)
                    if current_uptime.seconds >= 150:
                        print(f"Server uptime is {current_uptime.seconds} i.e. more than 60 seconds. Proceeding with restart.")
                        send_notification(msg)
                        restart_server_and_service()
                    else:
                        print("Server uptime is less than 60 seconds. Waiting...")
    

def restart_server_and_service():
    print("Recreating instance via terraform >> taint >> plan >> apply \n Please Wait...")
    os.system("terraform taint aws_instance.ec2_instance && terraform plan -out 'main.tfplan' && terraform apply 'main.tfplan' ")
    print("Instance recreated.. Waiting service to start")
    time.sleep(20)

schedule.every(5).seconds.do(check_instance_status)
while True:
    schedule.run_pending()
