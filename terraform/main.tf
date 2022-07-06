
############################################################################
# Guardduty Detector
############################################################################
resource "aws_guardduty_detector" "example" {
  enable                       = true
  finding_publishing_frequency = "SIX_HOURS"
  tags                         = {}
  datasources {
    s3_logs {
      enable = true
    }
  }
}

############################################################################
# EventBrige
############################################################################
# Event rule
resource "aws_cloudwatch_event_rule" "example" {
  event_bus_name = "default"
  event_pattern  = file("${path.module}/policy/event.json")
  is_enabled     = true
  name           = "event-chatbot-guardduty"
  tags           = {}
}

# Event target
resource "aws_cloudwatch_event_target" "example" {
  arn            = aws_sns_topic.example.arn
  event_bus_name = "default"
  rule           = aws_cloudwatch_event_rule.example.name
}

############################################################################
# SNS
############################################################################
# SNS topic
resource "aws_sns_topic" "example" {
  application_success_feedback_sample_rate = 0
  content_based_deduplication              = false
  fifo_topic                               = false
  firehose_success_feedback_sample_rate    = 0
  http_success_feedback_sample_rate        = 0
  kms_master_key_id                        = "alias/aws/sns"
  name                                     = "sns-topic-chatbot-guardduty"
  policy                                   = file("${path.module}/policy/sns.json")
  sqs_success_feedback_sample_rate         = 0
  tags                                     = {}
}

############################################################################
# IAMロール
############################################################################
# Chatbot用
resource "aws_iam_role" "example" {
  assume_role_policy    = file("${path.module}/policy/iam-chatbot-trust.json")
  force_detach_policies = true
  managed_policy_arns = [aws_iam_policy.example.arn]
  max_session_duration = 3600
  name                 = "aws-chatbot-role"
  path                 = "/service-role/"
  tags                 = {}
}

############################################################################
# IAMポリシー
############################################################################
# ChatbotのIAMロール用
resource "aws_iam_policy" "example" {
  description = "NotificationsOnly policy for AWS-Chatbot"
  name        = "aws-chatbot-policy"
  path        = "/service-role/"
  policy      = file("${path.module}/policy/iam-chatbot.json")
  tags        = {}
}

############################################################################
# Chatbot
############################################################################
# https://github.com/waveaccounting/terraform-aws-chatbot-slack-configuration
module "chatbot_slack_configuration_example" {
  source  = "waveaccounting/chatbot-slack-configuration/aws"
  version = "1.1.0"

  configuration_name = "chatbot-guardduty"
  guardrail_policies = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
  iam_role_arn       = aws_iam_role.example.arn
  logging_level      = "ERROR"
  slack_channel_id   = "＜SlackチャンネルID＞"
  slack_workspace_id = "＜SlackワークスペースID＞"
  sns_topic_arns     = [aws_sns_topic.example.arn]
  user_role_required = false
  tags = {}
}
