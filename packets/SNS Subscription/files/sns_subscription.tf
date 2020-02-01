#set ($topicName = $instance.parent.getAttribute("topic_name"))
#set ($subscriptionName = $instance.getAttribute("subscription_name"))
#set ($filterPolicy = $instance.getAttribute("filter_policy").trim())
#set ($deliveryPolicy = $instance.getAttribute("delivery_policy").trim())
#set ($tmpEndpoint = $instance.getAttribute("subscription_endpoint"))
#set ($protocol = $instance.getAttribute("protocol"))

#set ($targetInstance = $instance.getInstanceByAttributeVelocityName("subscription_endpoint", true, false))
#if ($protocol == "sqs")
	#if ($targetInstance)
		#if ($targetInstance.packetType != "AWS-SQS-QUEUE")
			#set ($message = "Target subscription endpoint should be of packet type 'AWS-SQS-QUEUE', not '" + $targetInstance.packetType + "'.")
			$environment.throwException($message)
		#else
			#set ($endpoint = "aws_sqs_queue." + ${targetInstance.getAttribute("queue_name")} + ".arn")
		#end
	#else
		#if ($tmpEndpoint.startsWith("arn"))
			#set ($endpoint = '"' + $tmpEndpoint + '"')
		#else
			$environment.throwException("Only arn endpoints or Velocity names are currently supported.")
		#end
	#end	
#else
	$environment.throwException("Only the 'sqs'-protocol is currently supported.")
#end

resource "aws_sns_topic_subscription" "$subscriptionName" {
  topic_arn 		= aws_sns_topic.${topicName}.arn
  protocol			= "$protocol"
  endpoint			= $endpoint
#if ($filterPolicy != "")  
  filter_policy = <<EOF
$filterPolicy
EOF
#end
#if ($deliveryPolicy != "")
  delivery_policy = <<EOF
$deliveryPolicy
EOF
#end

}


#if (! $instance.getParentInstanceByPacketType("TERRAFORM-AWS-RUNNER"))
provider "aws" {
  region = "us-east-1"
  version = "~> 2.32.0"
}

output "id" {
  description = "The ARN of the subscription"
  value       = "${D}{aws_sns_topic_subscription.${subscriptionName}.id}"
}

output "topic_arn" {
  description = "The ARN of the topic the subscription belongs to"
  value       = "${D}{aws_sns_topic_subscription.${subscriptionName}.topic_arn}"
}

output "protocol" {
  description = "The protocol being used"
  value       = "${D}{aws_sns_topic_subscription.${subscriptionName}.protocol}"
}

output "endpoint" {
  description = "The full endpoint to send data to (SQS ARN, HTTP(S) URL, Application ARN, SMS number, etc.)"
  value       = "${D}{aws_sns_topic_subscription.${subscriptionName}.endpoint}"
}

output "arn" {
  description = "The ARN of the subscription stored as a more user-friendly property"
  value       = "${D}{aws_sns_topic_subscription.${subscriptionName}.arn}"
}
#end
