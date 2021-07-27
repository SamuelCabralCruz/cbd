# CBD (UPLOAD)

- This action leverages the power of S3 and CloudFront to host multiple versions of the same website concurrently 
  with the same infrastructure components.

## Sample Usage

```
on: [pull_request]

[...]

- uses: SamuelCabralCruz/cbd/upload@vX.X.X
  with:
    project-name: <project-name> 
    bucket-name: <bucket-name> 
    cloudfront-dist-id: <cloudfront-dist-id>
    static-build-folder: <static-build-folder>
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
    AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

### Environment Variables

- GITHUB_TOKEN
  - Would normally be `${{ secrets.GITHUB_TOKEN }}`
  - Needed permissions:
    - `pull_requests: write`
- AWS_ACCESS_KEY_ID
  - AWS IAM User Access Key ID with S3 admin rights
  - Should be exposed via your repository secrets
- AWS_SECRET_ACCESS_KEY
  - AWS IAM User Secret Access Key with S3 admin rights
  - Should be exposed via your repository secrets
- AWS_REGION (optional - default: 'us-east-1')

### Inputs

- TODO
