import json

from example.lambda_function import lambda_handler


def test_lambda_handler_with_leap_year():
    response = lambda_handler({"year": "2024"}, {})

    assert response["statusCode"] == 200
    assert response["body"] == json.dumps(
        {
            "message": f"Hello! The year 2024 is a leap year.",
        }
    )


def test_lambda_handler_without_leap_year():
    response = lambda_handler({"year": "2025"}, {})

    assert response["statusCode"] == 200
    assert response["body"] == json.dumps(
        {
            "message": f"Hello! The year 2025 is not a leap year.",
        }
    )


def test_lambda_handler_logging_info(caplog):
    from example.lambda_function import logger

    logger.setLevel("INFO")

    lambda_handler({"year": "2024"}, {})

    assert "This is an info message." in caplog.text
