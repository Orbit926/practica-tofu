import re
import json


def lambda_handler(event, context):
    errors = []

    amount = event.get("amount")
    if not isinstance(amount, (int, float)) or amount <= 0:
        errors.append("amount must be a positive number")

    country = event.get("country", "")
    if not re.fullmatch(r"[A-Z]{2}", str(country)):
        errors.append("country must be a 2-letter ISO uppercase code (e.g. MX, US)")

    account = event.get("account", "")
    if not re.fullmatch(r"\d{4}-\d{4}", str(account)):
        errors.append("account must follow the format 1234-5678")

    event["is_valid"] = len(errors) == 0
    event["validation_errors"] = errors

    return event
