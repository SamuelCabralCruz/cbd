# CBD

- CBD (Commit Bucket Deploy, also known as Cannabidiol) is a GitHub Action that allow to deploy 
  static websites.
- The main idea behind this project was to have an easy way to concurrently deploy different versions 
  of a given static website.
- This project assumes that you are using AWS as a cloud provider.
- The core concept is to reuse the same infrastructure components to host different versions of the same website.

## Important Facts

- This action will only simplify the integration between your repository and your infrastructure.
  - Compute standardized folder name
  - Commenting pull requests with the proper url to the deployed website
  - Upload build to specified S3 bucket
  - Invalidate Cloudfront distribution after deployment
  - Clean up S3 bucket when pull request is closed
- The core value of this project resides in the proposed infrastructure.
- The proposed infrastructure can be summarized as follows:
  - S3 Bucket to host the different website's builds
  - Cloudfront CDN to distribute the static websites with standardized urls
    - Wildcard certificate on a specific subdomain to easily request our Cloudfront distribution
    - Lambda edge function to route to the proper folder in the bucket

## Sample Usage

- Before going any further, you must first have the appropriate infrastructure in place in your AWS account.
- For the moment, there is "out-of-the-box" way to proceed.
- Simply follow the instructions described [here](./set-up/README.md)
- This action is actually divided in three different parts made to match your project lifecycle:
  - [Upload](./upload/README.md)
  - [Update](./update/README.md)
  - [Deploy](./deploy/README.md)
