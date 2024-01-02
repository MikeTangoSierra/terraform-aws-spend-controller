# -*- coding: utf-8 -*-

"""Module deleting all dynamodb tables and backups."""

from typing import Iterator

from botocore.exceptions import ClientError, EndpointConnectionError

from nuke.client_connections import AwsClient
from nuke.exceptions import nuke_exceptions


class NukeDynamodb:
    """Abstract dynamodb nuke in a class."""

    def __init__(self, region_name=None) -> None:
        """Initialize dynamodb nuke."""
        self.dynamodb = AwsClient().connect("dynamodb", region_name)

        try:
            self.dynamodb.list_tables()
        except EndpointConnectionError:
            print("Dynamodb resource is not available in this aws region")
            return

    def nuke(self, older_than_seconds: float) -> None:
        """Dynamodb table and backup deleting function.

        Deleting all dynamodb table and backup with a timestamp greater
        than older_than_seconds.

        :param int older_than_seconds:
            The timestamp in seconds used from which the aws
            resource will be deleted
        """
        for table in self.list_tables(older_than_seconds):
            try:
                self.dynamodb.delete_table(TableName=table)
                print("Nuke dynamodb table{0}".format(table))
            except ClientError as exc:
                nuke_exceptions("dynamodb table", table, exc)

        for backup in self.list_backups(older_than_seconds):
            try:
                self.dynamodb.delete_backup(BackupArn=backup)
                print("Nuke dynamodb backup {0}".format(backup))
            except ClientError as exc:
                nuke_exceptions("dynamodb backup", backup, exc)

    def list_tables(self, time_delete: float) -> Iterator[str]:
        """Dynamodb table list function.

        List names of all dynamodb tables with a timestamp lower than
        time_delete.

        :param int time_delete:
            Timestamp in seconds used for filter dynamodb tables

        :yield Iterator[str]:
            Dynamodb tables names
        """
        paginator = self.dynamodb.get_paginator("list_tables")

        for page in paginator.paginate():
            for table in page["TableNames"]:
                table_desc = self.dynamodb.describe_table(TableName=table)
                date_table = table_desc["Table"]["CreationDateTime"]
                if date_table.timestamp() < time_delete:
                    yield table

    def list_backups(self, time_delete: float) -> Iterator[str]:
        """Dynamodb backup list function.

        List arn of all dynamodb backup with a timestamp lower than
        time_delete.

        :param int time_delete:
            Timestamp in seconds used for filter dynamodb backup

        :yield Iterator[str]:
            Dynamodb backup arn
        """
        paginator = self.dynamodb.get_paginator("list_backups")

        for page in paginator.paginate():
            for backup in page["BackupSummaries"]:
                backup_desc = self.dynamodb.describe_backup(
                    BackupArn=backup["BackupArn"]["BackupDescription"]
                )
                desc = backup_desc["BackupDetails"]
                if desc["BackupCreationDateTime"].timestamp() < time_delete:
                    yield backup["BackupArn"]
