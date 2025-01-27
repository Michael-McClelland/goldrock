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