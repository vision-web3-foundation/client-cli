"""Common exceptions for the Vision Client CLI.

"""
from vision.client.library.exceptions import ClientError


class ClientCliError(ClientError):
    """Base exception class for all Vision client CLI errors.

    """
    pass
