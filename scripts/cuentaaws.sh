AWS_ACCOUNT_ID="244906337823"   # ← tu cuenta real

aws iam list-open-id-connect-providers \
  --query "OpenIDConnectProviderList[].Arn" --output text | grep -q token.actions.githubusercontent.com || \
aws iam create-open-id-connect-provider \
  --url "https://token.actions.githubusercontent.com" \
  --client-id-list "sts.amazonaws.com" \
  --thumbprint-list "6938fd4d98bab03faadb97b34396831e3780aea1"
