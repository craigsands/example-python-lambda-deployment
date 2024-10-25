import json

import pendulum
from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities.parser import event_parser, BaseModel
from aws_lambda_powertools.utilities.typing import LambdaContext

logger = Logger()


class Event(BaseModel):
    year: str


@event_parser(model=Event)
def lambda_handler(event: Event, context: LambdaContext) -> dict:
    logger.info("This is an info message.")

    is_leap_year = pendulum.parse(event.year).is_leap_year()
    return {
        "statusCode": 200,
        "body": json.dumps(
            {
                "message": f"Hello! The year {event.year} is{'' if is_leap_year else ' not'} a leap year.",
            }
        ),
    }
