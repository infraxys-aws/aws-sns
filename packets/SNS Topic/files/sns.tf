#set ($topicName = $instance.getAttribute("topic_name"))
#set ($snsPolicy = $instance.getAttribute("sns_policy").trim())
#set ($deliveryPolicy = $instance.getAttribute("delivery_policy").trim())

resource "aws_sns_topic" "$topicName" {
  name = "$topicName"
  display_name = "$instance.getAttribute("display_name")"
#if ($snsPolicy != "")  
  policy = <<EOF
$snsPolicy
EOF
#end
#if ($deliveryPolicy != "")
  delivery_policy = <<EOF
$deliveryPolicy
EOF
#end

  application_success_feedback_role_arn = "$instance.getAttribute("application_success_feedback_role_arn")"
  application_success_feedback_sample_rate = $instance.getAttribute("application_success_feedback_sample_rate")
  application_failure_feedback_role_arn = "$instance.getAttribute("application_failure_feedback_role_arn")"
  
  http_success_feedback_role_arn = "$instance.getAttribute("http_success_feedback_role_arn")"
  http_success_feedback_sample_rate = $instance.getAttribute("http_success_feedback_sample_rate")
  http_failure_feedback_role_arn = "$instance.getAttribute("http_failure_feedback_role_arn")"
  
  kms_master_key_id = "$instance.getAttribute("kms_master_key_id")"
  
  lambda_success_feedback_role_arn = "$instance.getAttribute("lambda_success_feedback_role_arn")"
  lambda_success_feedback_sample_rate = $instance.getAttribute("lambda_success_feedback_sample_rate")
  lambda_failure_feedback_role_arn = "$instance.getAttribute("lambda_failure_feedback_role_arn")"
  
  sqs_success_feedback_role_arn = "$instance.getAttribute("sqs_success_feedback_role_arn")"
  sqs_success_feedback_sample_rate = $instance.getAttribute("sqs_success_feedback_sample_rate")
  sqs_failure_feedback_role_arn = "$instance.getAttribute("sqs_failure_feedback_role_arn")"
  
  
  tags = {
$instance.getAttribute("tags")
  }
}

#if (! $instance.getParentInstanceByPacketType("TERRAFORM-AWS-RUNNER"))
provider "aws" {
  region = "us-east-1"
  version = "~> 2.32.0"
}

output "id" {
  description = "The ARN of the SNS topic"
  value       = "${D}{aws_sns_topic.${topicName}.id}"
}

output "arn" {
  description = "The ARN of the SNS topic, as a more obvious property (clone of id)"
  value       = "${D}{aws_sns_topic.${topicName}.arn}"
}
#end
