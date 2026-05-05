import json


def lambda_handler(event, context):
    reasons = []

    if not event.get("is_valid", True):
        event["risk_level"] = "invalid"
        event["risk_reasons"] = ["Transaction failed validation"]
        return event

    amount = event.get("amount", 0)
    country = event.get("country", "")

    if amount > 10000:
        reasons.append(f"Amount {amount} exceeds high-risk threshold of 10000")

    if country != "MX":
        reasons.append(f"Foreign country detected: {country}")

    if reasons:
        event["risk_level"] = "high"
    else:
        event["risk_level"] = "low"

    event["risk_reasons"] = reasons

    return event
