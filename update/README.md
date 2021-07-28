# CBD (UPDATE)

Clean up S3 bucket when pull requests are closed.

## Sample Usage

```
on:
  pull_request:
    types: [closed]

jobs:
  update:
    runs-on: ubuntu-latest
    
    steps:
      - uses: SamuelCabralCruz/cbd/update@vX.X.X
        with:
          project-name: <project-name> 
          bucket-name: <bucket-name> 
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```
> This can easily be adapted using a matrix strategy when using the action for multiple projects inside same repository.

### Environment Variables

- AWS_ACCESS_KEY_ID
  - AWS IAM User Access Key ID with S3 admin rights
  - Should be exposed via your repository secrets
- AWS_SECRET_ACCESS_KEY
  - AWS IAM User Secret Access Key with S3 admin rights
  - Should be exposed via your repository secrets
- AWS_REGION (optional - default: 'us-east-1')

### Inputs

- project-name
  - Lower kebab case string (lower-kebab-case-string) allowing to store action's data from multiple
  projects/repositories without collisions in the same bucket.
- bucket-name
  - S3 bucket name to be used to host static websites.
