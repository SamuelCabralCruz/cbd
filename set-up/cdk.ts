// @ts-nocheck

import * as acm from '@aws-cdk/aws-certificatemanager'
import * as cf from '@aws-cdk/aws-cloudfront'
import * as iam from '@aws-cdk/aws-iam'
import * as lambda from '@aws-cdk/aws-lambda'
import * as route53 from '@aws-cdk/aws-route53'
import * as route53Targets from '@aws-cdk/aws-route53-targets'
import * as s3 from '@aws-cdk/aws-s3'
import * as cdk from '@aws-cdk/core'

export type MultipleStaticWebsitesConstructProps = {
    scope: cdk.Construct
    constructId: string
    domainName: string
    subdomainName: string
    hostedZoneId: string
    hostedZoneName: string
    bucketName: string
}

// Sample Usage
// new MultipleStaticWebsitesConstruct({
//   scope: this,
//   constructId: 'storybook',
//   domainName: 'example.com',
//   subdomainName: 'storybook',
//   hostedZoneId: 'Z08722683B2KZFQT3OA0N',
//   hostedZoneName: 'example.com',
// })

export class MultipleStaticWebsitesConstruct extends cdk.Construct {
    constructor(props: MultipleStaticWebsitesConstructProps) {
        const {
            scope,
            constructId,
            domainName,
            subdomainName,
            hostedZoneId,
            hostedZoneName,
            bucketName,
        } = props
        super(scope, `${constructId}-multiple-static-websites`)

        // Create wildcard certificate for specified subdomain
        const baseHostedZone = route53.HostedZone.fromHostedZoneAttributes(
            scope,
            `${constructId}-hosted-zone`,
            {
                hostedZoneId,
                zoneName: hostedZoneName,
            },
        )
        const wildcardDomainName = `*.${subdomainName}.${domainName}`
        const wildcardCertificate = new acm.Certificate(scope, `${constructId}-wildcard-certificate`, {
            domainName: wildcardDomainName,
            validation: acm.CertificateValidation.fromDns(baseHostedZone),
        })

        // Create s3 bucket to host static websites
        const bucket = new s3.Bucket(scope, `${constructId}-bucket`, {
            bucketName,
            websiteIndexDocument: 'index.html',
        })
        const bucketPermission = new iam.PolicyStatement({
            principals: [new iam.AnyPrincipal()],
            resources: [bucket.arnForObjects('*')],
            actions: ['s3:GetObject'],
            conditions: {
                StringLike: {
                    'aws:Referer': ['http', 'https'].map((protocol) => `${protocol}://${domainName}/*`),
                },
            },
        })
        bucket.addToResourcePolicy(bucketPermission)

        // Create routing lambda edge function to be used by cloudfront distribution and publish a version
        const routingLambda = new lambda.Function(scope, `${constructId}-routing-lambda`, {
            runtime: lambda.Runtime.NODEJS_12_X,
            handler: 'index.handler',
            code: new lambda.InlineCode(`
        exports.handler = (event, context, callback) => {
          const originalDomain = "${domainName}";
          const bucketUrl = "${bucket.bucketWebsiteUrl}";

          const redirectedDomain = bucketUrl.replace('http://', '');
          const request = event.Records[0].cf.request;
          const host = request.headers.host[0].value.replace(/^www\\./, "");
          const subdomainPattern = new RegExp(\`^[a-z0-9]+\\\\.\${originalDomain
            .replace('*\\.', '')
            .replace(/[.*+?^\${}()|[\\]\\\\]/g, '\\\\$&')}$\`);
          const dir = subdomainPattern.test(host) ? host.split(".")[0] : undefined;
          const entryPoint = dir ? \`/\${dir}\` : "";

          request.origin = {
            custom: {
              domainName: redirectedDomain,
              port: 80,
              protocol: "http",
              path: entryPoint,
              sslProtocols: ["TLSv1.1", "TLSv1.2"],
              readTimeout: 5,
              keepaliveTimeout: 5,
              customHeaders: {
                referer : [{ key: "referer", value: \`http://\${host}/\` }]
              }
            }
          };

          request.headers["host"] = [{ key: "host", value: redirectedDomain }];
          callback(null, request);
        };`),
            timeout: cdk.Duration.seconds(10),
        })
        const version = new lambda.Version(scope, `${constructId}-routing-lambda-version`, {
            lambda: routingLambda,
        })
        version.addPermission(`${constructId}-routing-lambda-version-permission`, {
            principal: new iam.ServicePrincipal('edgelambda.amazonaws.com'),
            action: 'lambda:GetFunction',
        })

        // Create cloudfront distribution to distribute our websites to standardized urls
        const cloudfrontDistribution = new cf.CloudFrontWebDistribution(
            scope,
            `${constructId}-cloudfront-distribution`,
            {
                priceClass: cf.PriceClass.PRICE_CLASS_100,
                viewerCertificate: cf.ViewerCertificate.fromAcmCertificate(wildcardCertificate, {
                    sslMethod: cf.SSLMethod.SNI,
                    securityPolicy: cf.SecurityPolicyProtocol.TLS_V1_2_2019,
                    aliases: [domainName],
                }),
                originConfigs: [
                    {
                        behaviors: [
                            {
                                isDefaultBehavior: true,
                                forwardedValues: {
                                    queryString: true,
                                    headers: ['host'],
                                },
                                lambdaFunctionAssociations: [
                                    {
                                        eventType: cf.LambdaEdgeEventType.ORIGIN_REQUEST,
                                        lambdaFunction: version,
                                    },
                                ],
                            },
                        ],
                        s3OriginSource: {
                            s3BucketSource: bucket,
                            originAccessIdentity: new cf.OriginAccessIdentity(
                                scope,
                                `${constructId}-origin-access-identity`,
                            ),
                        },
                    },
                ],
            },
        )

        // Create dns record for cloudfront distribution in hosted zone
        const target = route53.RecordTarget.fromAlias(
            new route53Targets.CloudFrontTarget(cloudfrontDistribution),
        )
        new route53.ARecord(scope, `${constructId}-dns-record`, {
            zone: baseHostedZone,
            recordName: `*.${subdomainName}`,
            target,
        })
    }
}
