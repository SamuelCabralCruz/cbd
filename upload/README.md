# CBD (UPLOAD)

Upload static build files on pull request event.

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

- project-name
  - Lower kebab case string (lower-kebab-case-string) allowing to store action's data from multiple
    projects/repositories without collisions in the same bucket.
- bucket-name
  - S3 bucket name to be used to host static websites.
- cloudfront-dist-id
  - CloudFront distribution id fronting the s3 bucket.
- static-build-folder
  - Relative path from root of the repository to the folder containing all the static files to be deployed.
