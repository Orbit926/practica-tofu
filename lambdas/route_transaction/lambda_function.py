import json
import os
import boto3
from datetime import datetime, timezone


s3_client = boto3.client("s3")


def lambda_handler(event, context):
    bucket_name = os.environ["BUCKET_NAME"]

    is_valid = event.get("is_valid", False)
    risk_level = event.get("risk_level", "invalid")

    if not is_valid:
        route = "invalid"
    elif risk_level == "high":
        route = "review"
    else:
        route = "approved"

    transaction_id = event.get("transaction_id", "unknown")
    timestamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    s3_key = f"{route}/{transaction_id}-{timestamp}.json"

    s3_client.put_object(
        Bucket=bucket_name,
        Key=s3_key,
        Body=json.dumps(event),
        ContentType="application/json",
    )

    event["route"] = route
    event["s3_bucket"] = bucket_name
    event["s3_key"] = s3_key

    return event
