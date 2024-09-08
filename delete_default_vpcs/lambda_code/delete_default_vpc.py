import boto3
import os
import json
from botocore.exceptions import ClientError

def handler(e, c):
  print("REQUEST RECEIVED:\n" + json.dumps(e))
  if 'source' in e: print('Scheduled Event')
  if 'RequestType' in e:
    print('curl -H \'Content-Type: \'\'\' -X PUT -d \'{\n'
          '   "Status": "SUCCESS",\n'
          '   "PhysicalResourceId": "' + e['LogicalResourceId'] + '",\n'
          '   "StackId": "' + e['StackId'] + '",\n'
          '   "RequestId": "' + e['RequestId'] + '",\n'
          '   "LogicalResourceId": "' + e['LogicalResourceId'] + '"\n'
          '}\' \'' + e['ResponseURL'] + '\''
          )
  
  regions = grab_region_list()
  accounts = grab_org_list()
  role_name = os.environ["ORG_ADMIN_ROLE_NAME"]

  print("Initiated with variables:", regions, accounts, role_name)
  core_functions(regions, accounts, role_name)


def grab_region_list():
  regions = boto3.client('ec2').describe_regions(AllRegions=False)
  region_list = []
  for region in regions['Regions']: region_list.append(region['RegionName'])
  return region_list


def grab_org_list():
  org = boto3.client('organizations')
  paginator = org.get_paginator('list_accounts')
  account_list = []
  account_iterator = paginator.paginate()
  for page in account_iterator:
    for acct in page['Accounts']:
      account_list.append(acct['Id'])
  return account_list


def core_functions(regions, accounts, role):
  for account in accounts:
    for region in regions:
      if account == os.environ["MAIN_ACCOUNT_ID"]:
        ec2_client = boto3.client('ec2', region_name=region)
      else:
        session = assume_role(account, 'DeleteDefaultVPCLambda', boto3.client('sts'), role)
        ec2_client = session.client('ec2', region_name=region) 
      print('Working in account: ', account, ' in ', region)
      rm_vpc(ec2_client, region)


def assume_role(account_id, session_name, sts, role):
  resp = sts.assume_role(RoleArn='arn:aws:iam::' + account_id + ':role/' + role,
                        RoleSessionName=session_name)
  return boto3.Session(aws_access_key_id=resp['Credentials']['AccessKeyId'],
                      aws_secret_access_key=resp['Credentials']['SecretAccessKey'],
                      aws_session_token=resp['Credentials']['SessionToken'])


def rm_vpc(ec2, region):
  try:
    attribs=ec2.describe_account_attributes(AttributeNames=['default-vpc'])['AccountAttributes']
  except ClientError as e:
    print(e.response['Error']['Message'])
  else:
    vpc_id=attribs[0]['AttributeValues'][0]['AttributeValue']

  if vpc_id=='none':
    print('VPC (default) was not found in the {} region.'.format(region))

  args={'Filters':[{'Name':'vpc-id','Values':[vpc_id]}]}
  try:
    eni=ec2.describe_network_interfaces(**args)['NetworkInterfaces']
  except ClientError as e:
    print(e.response['Error']['Message'])

  if eni:
    print('VPC {} has existing resources in the {} region.'.format(vpc_id,region))
  del_igw(ec2,vpc_id)
  del_subs(ec2,args)
  del_rtbs(ec2,args)
  del_acls(ec2,args)
  del_sgps(ec2,args)
  del_vpc(ec2,vpc_id,region)


def del_igw(ec2,vpc_id):
  args={'Filters':[{'Name':'attachment.vpc-id','Values':[vpc_id]}]}
  igw=[]
  try: igw=ec2.describe_internet_gateways(**args)['InternetGateways']
  except ClientError as e: print(e.response['Error']['Message'])
  if igw:
    igw_id=igw[0]['InternetGatewayId']
    try: ec2.detach_internet_gateway(InternetGatewayId=igw_id,VpcId=vpc_id)
    except ClientError as e: print(e.response['Error']['Message'])
    try: ec2.delete_internet_gateway(InternetGatewayId=igw_id)
    except ClientError as e: print(e.response['Error']['Message'])
  return


def del_subs(ec2,args):
  subs=[]
  try: subs=ec2.describe_subnets(**args)['Subnets']
  except ClientError as e: print(e.response['Error']['Message'])
  if subs:
    for sub in subs:
      sub_id=sub['SubnetId']
      try: ec2.delete_subnet(SubnetId=sub_id)
      except ClientError as e: print(e.response['Error']['Message'])
  return


def del_rtbs(ec2,args):
  rtbs=[]
  try: rtbs=ec2.describe_route_tables(**args)['RouteTables']
  except ClientError as e: print(e.response['Error']['Message'])
  if rtbs:
    for rtb in rtbs:
      main='false'
      for assoc in rtb['Associations']:
        main=assoc['Main']
      if main: continue
      rtb_id=rtb['RouteTableId']
      try: ec2.delete_route_table(RouteTableId=rtb_id)
      except ClientError as e: print(e.response['Error']['Message'])
  return


def del_acls(ec2,args):
  acls=[]
  try: acls=ec2.describe_network_acls(**args)['NetworkAcls']
  except ClientError as e: print(e.response['Error']['Message'])
  if acls:
    for acl in acls:
      default=acl['IsDefault']
      if default: continue
      acl_id=acl['NetworkAclId']
      try: ec2.delete_network_acl(NetworkAclId=acl_id)
      except ClientError as e: print(e.response['Error']['Message'])
    return


def del_sgps(ec2,args):
  sgps=[]
  try: sgps=ec2.describe_security_groups(**args)['SecurityGroups']
  except ClientError as e: print(e.response['Error']['Message'])
  if sgps:
    for sgp in sgps:
      default=sgp['GroupName']
      if default=='default': continue
      sg_id=sgp['GroupId']
      try: ec2.delete_security_group(GroupId=sg_id)
      except ClientError as e: print(e.response['Error']['Message'])
  return


def del_vpc(ec2,vpc_id,region):
  try: ec2.delete_vpc(VpcId=vpc_id)
  except ClientError as e: print(e.response['Error']['Message'])
  else: print('VPC {} has been deleted from the {} region.'.format(vpc_id,region))
  return
