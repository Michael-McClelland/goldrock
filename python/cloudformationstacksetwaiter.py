import time
import boto3
organizations_client = boto3.client('organizations')
paginator = organizations_client.get_paginator('list_accounts')
organizations_list_accounts_iterator = paginator.paginate()
organizations_account_set = set([])
for accounts in organizations_list_accounts_iterator:        
  for account in accounts['Accounts']:
    if account['Status'] == 'ACTIVE' and account['Id'] != ():
      organizations_account_set.add(account['Id'])
organization_response = organizations_client.describe_organization()
organizations_account_set.remove(organization_response['Organization']['MasterAccountId'])
cloudformation_stack_instances_set = set([])
while ( not organizations_account_set.issubset(cloudformation_stack_instances_set)):
  cloudformation_stack_instances_set = set([])
  cloudformation_client = boto3.client('cloudformation')
  paginator = cloudformation_client.get_paginator('list_stack_instances')
  paginator_iterator = paginator.paginate(
    StackSetName='goldrock-github-actions',
    Filters=[
      {
        'Name': 'DETAILED_STATUS',
        'Values': 'SUCCEEDED'
      },
    ]
  )
  for keys in paginator_iterator:
    for keyitem in keys['Summaries']:
      cloudformation_stack_instances_set.add(keyitem['Account'])
  time.sleep(5)