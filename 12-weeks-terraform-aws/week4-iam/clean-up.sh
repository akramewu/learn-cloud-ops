# 1. Get custom policy ARN
POLICY_ARN=$(aws iam list-policies --scope Local \
  --query 'Policies[?PolicyName==`week4-iam-s3-readonly-policy`].Arn' \
  --output text)

echo "Policy ARN: $POLICY_ARN"

# 2. Detach custom S3 policy
aws iam detach-role-policy \
  --role-name week4-iam-ec2-role \
  --policy-arn $POLICY_ARN

# 3. Remove role from correct instance profile
aws iam remove-role-from-instance-profile \
  --instance-profile-name week4-iam-ec2-instance-profile \
  --role-name week4-iam-ec2-role

# 4. Delete instance profile
aws iam delete-instance-profile \
  --instance-profile-name week4-iam-ec2-instance-profile

# 5. Delete role
aws iam delete-role --role-name week4-iam-ec2-role

# 6. Delete custom policy
aws iam delete-policy --policy-arn $POLICY_ARN

echo "✅ All cleaned up!"