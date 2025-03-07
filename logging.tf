resource "aws_cloudwatch_log_group" "logGroup" {
    name = "arc-log-group"
    retention_in_days = 30
}

resource "aws_cloudwatch_log_stream" "logStream" {
    name = "arc-api-logs"
    log_group_name = aws_cloudwatch_log_group.logGroup.name
}

resource "aws_cloudwatch_log_stream" "logStream2" {
    name = "arc-logs"
    log_group_name = aws_cloudwatch_log_group.logGroup.name
}

resource "aws_cloudwatch_log_stream" "logStream3" {
    name = "unity-logs"
    log_group_name = aws_cloudwatch_log_group.logGroup.name
}