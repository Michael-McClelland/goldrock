# goldrock
GoldRock

## bugs 
CloudTrail has to be deployed from management account because TF halts on creating trail from delgate due to a race condition on describing a delegated trail



{
    "Version": "2012-10-17",
    "Statement": 
    [
    {
        "Sid": "PolicyGenerationPermissions",
        "Effect": "Allow",
        "Principal": {
            "AWS": "*"
        },
        "Action": [
            "s3:GetObject",
            "s3:ListBucket"
        ],
        "Resource": [
            "arn:aws:s3:::<organization-bucket-name>",
			"arn:aws:s3:::<organization-bucket-name>/<optional-prefix-provided-by-customer>/AWSLogs/<organization-id>/${aws:PrincipalAccount}/*"
        ],
        "Condition": {
"StringEquals":{
"aws:PrincipalOrgID":"<organization-id>"
},

            "StringLike": {"aws:PrincipalArn":"arn:aws:iam::${aws:PrincipalAccount}:role/service-role/AccessAnalyzerMonitorServiceRole*"            }
        }
    }
    ]
}



putbucketacl condition key? x-amz-acl?






Isengard -> Create Account

Immediately delete OrthancRole to stop guardduty

Wait 40 minutes
Disable any GuardDuty Created

Create Organization

Activate Organizational Trust of Cloudformation StackSets





####helper script
awsRegionList=$(aws ec2 describe-regions | jq -r '.Regions[] | .RegionName')
for region in $awsRegionList
do
    echo " working on : ${region}"
    DETECTORID=$(aws guardduty list-detectors --region ${region} | jq -r '.DetectorIds[]')
    aws guardduty delete-detector --detector-id $DETECTORID
done