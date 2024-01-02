# -*- coding: utf-8 -*-

"""Module deleting all aws Elastic Container Registry resources."""

from typing import Iterator

from botocore.exceptions import ClientError, EndpointConnectionError

from nuke.client_connections import AwsClient
from nuke.exceptions import nuke_exceptions


class NukeEcr:
    """Abstract ecr nuke in a class."""

    def __init__(self, region_name=None) -> None:
        """Initialize ecr nuke."""
        self.ecr = AwsClient().connect("ecr", region_name)

        try:
            self.ecr.describe_repositories()
        except EndpointConnectionError:
            print("Ecr resource is not available in this aws region")
            return

    def nuke(self, older_than_seconds: float) -> None:
        """Elastic Container Registry deleting function.

        Deleting all Elastic Container Registry with a timestamp greater
        than older_than_seconds.

        :param int older_than_seconds:
            The timestamp in seconds used from which the aws
            resource will be deleted
        """
        for registry in self.list_registry(older_than_seconds):
            try:
                self.ecr.delete_repository(repositoryName=registry, force=True)
                print("Nuke ECR Registry{0}".format(registry))
            except ClientError as exc:
                nuke_exceptions("ecr registry", registry, exc)

    def list_registry(self, time_delete: float) -> Iterator[str]:
        """Elastic Container Registry list function.

        List the names of all Elastic Container Registry with
        a timestamp lower than time_delete.

        :param int time_delete:
            Timestamp in seconds used for filter ECR

        :yield Iterator[str]:
            Elastic Container Registry names
        """
        paginator = self.ecr.get_paginator("describe_repositories")

        for page in paginator.paginate():
            for registry in page["repositories"]:
                if registry["createdAt"].timestamp() < time_delete:
                    yield registry["repositoryName"]
