from boto3 import session
import boto3
import botocore
import os
import time

account_id = boto3.client('sts').get_caller_identity().get('Account')
session = session.Session()
partition = session.get_partition_for_region(region_name=os.environ['PY_HOME_REGION'])


s3_client = boto3.client('s3')
try:
  s3_response = s3_client.head_bucket(
    Bucket='goldrock-tfstate-' + account_id + '-' + os.environ['PY_REGION'],
    ExpectedBucketOwner=account_id
  )
  bucket_exists = True
except botocore.exceptions.ClientError:
  bucket_exists = False
if not bucket_exists and os.environ['PY_REGION'] != 'us-east-1':
  s3_client.create_bucket(
  Bucket='goldrock-tfstate-' + account_id + '-' + os.environ['PY_REGION'], 
  CreateBucketConfiguration={'LocationConstraint': os.environ['PY_REGION']}
  )
if not bucket_exists and os.environ['PY_REGION'] == 'us-east-1':
  s3_client.create_bucket(
  Bucket='goldrock-tfstate-' + account_id + '-' + os.environ['PY_REGION']
  )
######

kms_home_region_client = boto3.client('kms', region_name=os.environ['PY_HOME_REGION'])
kms_home_region_response = kms_home_region_client.describe_key(
  KeyId='arn:' +  partition + ':kms:' + os.environ['PY_HOME_REGION'] + ':' + account_id + ':alias/goldrock-tfstate'
)
kms_client = boto3.client('kms',region_name=os.environ['PY_REGION'])
try:
  kms_replica_region_response = kms_client.describe_key(
    KeyId='arn:' +  partition + ':kms:' + os.environ['PY_REGION'] + ':' + account_id + ':key/' + kms_home_region_response['KeyMetadata']['KeyId']
  )
  key_exists = True
except kms_client.exceptions.NotFoundException:
  key_exists = False
if not key_exists:
  response = kms_home_region_client.replicate_key(
    KeyId=kms_home_region_response['KeyMetadata']['KeyId'],
    ReplicaRegion=os.environ['PY_REGION'],
    BypassPolicyLockoutSafetyCheck=False
  )
  key_ready = False
  while ( not key_ready ):
    time.sleep(90)
    kms_replica_region_ready_response = kms_client.describe_key(
      KeyId='arn:' +  partition + ':kms:' + os.environ['PY_REGION'] + ':' + account_id + ':key/' + kms_home_region_response['KeyMetadata']['KeyId']
    )
    if kms_replica_region_ready_response['KeyMetadata']['KeyState'] == 'Enabled':
      key_ready = True
try:
  kms_replica_region_response_alias = kms_client.describe_key(
    KeyId='arn:' +  partition + ':kms:' + os.environ['PY_REGION'] + ':' + account_id + ':alias/goldrock-tfstate'
  )
  alias_exists = True
except kms_client.exceptions.NotFoundException:
  alias_exists = False
if not alias_exists:
  response = kms_client.create_alias(
    AliasName='alias/goldrock-tfstate',
    TargetKeyId=kms_home_region_response['KeyMetadata']['KeyId']
  )
######
dynamodb_client = boto3.client('dynamodb',region_name=os.environ['PY_REGION'])
try:
  dynamodb_describe_response = dynamodb_client.describe_table(
    TableName='goldrock-tfstate-' + account_id +'-' + os.environ['PY_REGION']
  )
  dynamodb_table_exists = True
except dynamodb_client.exceptions.ResourceNotFoundException:
  dynamodb_table_exists = False
if not dynamodb_table_exists:
  dynamodb_response = dynamodb_client.create_table(
    AttributeDefinitions=[
      {
        'AttributeName': 'LockID',
        'AttributeType': 'S'
      },
    ],
    TableName='goldrock-tfstate-' + account_id +'-' + os.environ['PY_REGION'],
    KeySchema=[
      {
        'AttributeName': 'LockID',
        'KeyType': 'HASH'
      },
    ],
    BillingMode='PROVISIONED',
    ProvisionedThroughput={
      'ReadCapacityUnits': 5,
      'WriteCapacityUnits': 5
    },
    SSESpecification={
      'Enabled': True,
      'SSEType': 'KMS',
      'KMSMasterKeyId': 'arn:' +  partition + ':kms:' + os.environ['PY_REGION'] + ':' + account_id + ':alias/goldrock-tfstate'
    },
    TableClass='STANDARD',
    DeletionProtectionEnabled=True
)
