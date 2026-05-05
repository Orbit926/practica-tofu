# Banking Transaction Processor

Serverless anti-fraud pipeline built with AWS Step Functions, AWS Lambda, and Amazon S3, deployed entirely through OpenTofu (Terraform-compatible IaC).

---

## What the Pipeline Does

Every banking transaction submitted to this pipeline goes through three automated stages:

1. **Validation** – structural and format checks on the input fields.
2. **Risk Assessment** – business-rule evaluation to classify the transaction as low or high risk.
3. **Routing** – the transaction is written to S3 under the appropriate prefix and a route decision is returned to Step Functions.

The Step Function then branches on the `route` field and ends in one of three terminal states: **Approved**, **ManualReview**, or **InvalidTransaction**.

---

## Architecture

```
Input JSON
    │
    ▼
[ValidateTransaction] ──► [RiskAssess] ──► [RouteTransaction]
                                                   │
                                            [RouteChoice]
                                           /       |       \
                                     approved   review   (default)
                                        │          │          │
                                   [Approved] [ManualReview] [InvalidTransaction]
                                   (Succeed)  (Succeed)      (Fail)
```

**AWS Resources created:**
- 1 S3 bucket for transaction results
- 3 Lambda functions (Python 3.12)
- 1 Step Functions State Machine (7 states)
- 2 IAM Roles (Lambda execution, Step Functions execution)
- Minimal IAM policies (CloudWatch Logs, S3 PutObject, Lambda InvokeFunction)

---

## Business Rules

### Validation (`validate_transaction`)
| Field     | Rule |
|-----------|------|
| `amount`  | Must be numeric and greater than 0 |
| `country` | Must match `[A-Z]{2}` (ISO 3166-1 alpha-2 uppercase) |
| `account` | Must match pattern `DDDD-DDDD` (e.g. `1234-5678`) |

Output fields added: `is_valid` (bool), `validation_errors` (list).

### Risk Assessment (`risk_assess`)
| Condition | Risk Level |
|-----------|------------|
| `is_valid == false` | `invalid` |
| `amount > 10000` OR `country != "MX"` | `high` |
| Otherwise | `low` |

Output fields added: `risk_level`, `risk_reasons`.

### Routing (`route_transaction`)
| Condition | Route | S3 Prefix |
|-----------|-------|-----------|
| `is_valid == false` | `invalid` | `invalid/` |
| `risk_level == "high"` | `review` | `review/` |
| `risk_level == "low"` | `approved` | `approved/` |

Output fields added: `route`, `s3_bucket`, `s3_key`.

---

## Constraints Met

| Requirement | Status |
|-------------|--------|
| Exactly 3 Lambda functions | ✅ |
| Exactly 1 Choice state | ✅ |
| Minimum 1 Fail state | ✅ (`InvalidTransaction`) |
| Minimum 1 Succeed state | ✅ (`Approved`, `ManualReview`) |
| Maximum 7 total states | ✅ (exactly 7) |
| No SNS / SQS / DynamoDB / API Gateway | ✅ |
| Deploy with `tofu apply` only | ✅ |
| `tofu destroy` cleans everything | ✅ (`force_destroy = true` on S3) |

---

## Deployment

### Prerequisites
- [OpenTofu](https://opentofu.org/docs/intro/install/) ≥ 1.6
- AWS CLI configured with credentials (`aws configure`)

### Steps

```bash
# 1. Initialise providers and modules
tofu init

# 2. Preview the execution plan
tofu plan

# 3. Deploy all resources
tofu apply
```

After a successful apply, the outputs will print:
- `s3_bucket_name` – bucket where results are stored
- `state_machine_arn` – ARN to use in test commands
- Lambda function names

---

## Testing with AWS CLI

Replace `<STATE_MACHINE_ARN>` with the value from `tofu output state_machine_arn`.

```bash
# Approved – low risk domestic transaction
aws stepfunctions start-execution \
  --state-machine-arn "<STATE_MACHINE_ARN>" \
  --input file://tests/approved_mx_low.json

# Manual review – large amount
aws stepfunctions start-execution \
  --state-machine-arn "<STATE_MACHINE_ARN>" \
  --input file://tests/review_large_amount.json

# Manual review – foreign country
aws stepfunctions start-execution \
  --state-machine-arn "<STATE_MACHINE_ARN>" \
  --input file://tests/review_foreign_country.json

# Invalid – bad input fields
aws stepfunctions start-execution \
  --state-machine-arn "<STATE_MACHINE_ARN>" \
  --input file://tests/invalid_transaction.json
```

---

## Verify Results in S3

```bash
# List all result objects
aws s3 ls s3://$(tofu output -raw s3_bucket_name)/ --recursive

# Download a specific result
aws s3 cp s3://$(tofu output -raw s3_bucket_name)/approved/tx-0001-<timestamp>.json -
```

---

## Destroy

```bash
tofu destroy
```

All resources including the S3 bucket and its contents will be removed.
