import boto3
cloudformation_client = boto3.client('cloudformation')
paginator = cloudformation_client.get_paginator('list_stack_sets')
paginator_iterator = paginator.paginate(
    Status='ACTIVE'#,
    #CallAs='SELF'|'DELEGATED_ADMIN',
)
for keys in paginator_iterator:
    for keyitem in keys['Keys']:
        print(keyitem)