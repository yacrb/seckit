# AWS Cloud Attacks Cheatsheet

## Identity / Caller Context

```bash
aws sts get-caller-identity
aws configure list
aws iam get-user
aws iam list-account-aliases
aws organizations describe-account --account-id <acct>
```

## Enumerate IAM

```bash
aws iam list-users
aws iam list-roles
aws iam list-groups
aws iam list-policies --scope Local
aws iam list-attached-user-policies --user-name <user>
aws iam list-user-policies --user-name <user>
aws iam list-role-policies --role-name <role>
aws iam list-attached-role-policies --role-name <role>
aws iam get-policy-version --policy-arn <arn> --version-id v1
```

## Assume Role / Privilege Escalation Checks

```bash
aws sts assume-role --role-arn arn:aws:iam::<acct>:role/<role> --role-session-name seckit
aws iam simulate-principal-policy --policy-source-arn <arn> --action-names iam:PassRole ec2:RunInstances lambda:CreateFunction
aws iam list-instance-profiles
aws iam get-role --role-name <role>
aws iam list-access-keys --user-name <user>
```

High-value checks:

- `iam:PassRole` + EC2/Lambda/Glue
- `sts:AssumeRole` on admin or automation roles
- `iam:CreatePolicyVersion` with `--set-as-default`
- `iam:AttachUserPolicy`, `iam:PutUserPolicy`, `iam:UpdateAssumeRolePolicy`
- `lambda:UpdateFunctionCode` on privileged functions

## S3

```bash
aws s3 ls
aws s3api list-buckets
aws s3 ls s3://<bucket> --recursive
aws s3api get-bucket-policy --bucket <bucket>
aws s3api get-bucket-acl --bucket <bucket>
aws s3api get-public-access-block --bucket <bucket>
aws s3api get-bucket-encryption --bucket <bucket>
aws s3api list-objects-v2 --bucket <bucket> --max-items 20
```

Misconfig quick hits:

- public bucket policy
- ACL grants to `AllUsers` or `AuthenticatedUsers`
- missing encryption
- static website bucket leaking backups or `.env`

## EC2 / Metadata / Fleet

```bash
aws ec2 describe-instances
aws ec2 describe-security-groups
aws ec2 describe-network-interfaces
aws ec2 describe-snapshots --owner-ids self
aws ec2 describe-images --owners self
aws ec2 describe-volumes
aws ec2 get-console-output --instance-id <id>
```

Privesc paths:

- attach existing admin instance profile
- modify user-data on stop/start workflows
- share / copy snapshots with exposed secrets

## Lambda / Serverless

```bash
aws lambda list-functions
aws lambda get-function --function-name <name>
aws lambda get-policy --function-name <name>
aws lambda list-event-source-mappings
aws logs describe-log-groups
aws logs tail /aws/lambda/<name> --follow
```

## CloudTrail / Logging

```bash
aws cloudtrail describe-trails
aws cloudtrail get-trail-status --name <trail>
aws cloudtrail lookup-events --max-results 20
aws logs describe-log-groups
aws configservice describe-configuration-recorders
aws guardduty list-detectors
```

Hunt for:

- `AssumeRole`
- `CreateAccessKey`
- `PutUserPolicy`
- `CreatePolicyVersion`
- `PassRole`
- `RunInstances`
- `UpdateFunctionCode`

## Prowler / ScoutSuite / Pacu

```bash
prowler aws -M csv json html
python3 tools/cloud/ScoutSuite/ScoutSuite.py aws --report-dir scoutsuite-report
pacu
```
