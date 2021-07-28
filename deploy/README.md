# CBD (DEPLOY)

Simple deploy your static website.

## Sample Usage

```
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
      - uses: SamuelCabralCruz/cbd/deploy@vX.X.X
        with:
          bucket-name: <bucket-name> 
          cloudfront-dist-id: <cloudfront-dist-id>
          source-dir: <source-dir>
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

- bucket-name
  - S3 bucket name to be used to host static websites.
- cloudfront-dist-id
  - CloudFront distribution id fronting the s3 bucket.
- source-dir
  - Relative path from root of the repository to the directory containing all the static files to be deployed.
- dest-dir (optional - default: '')
  - Relative path from root of the bucket to deploy the static files.
- perform-clean-up (optional - default: 'true')
  - Remove existing content in the destination directory before uploading source directory files.
