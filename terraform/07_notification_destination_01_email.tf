################################
### Notification Destination ###
################################

# Notification destination - Email
resource "newrelic_notification_destination" "email" {
  for_each = local.emails

  name       = each.key
  account_id = var.NEW_RELIC_ACCOUNT_ID
  type       = "EMAIL"

  property {
    key   = "email"
    value = each.value
  }
}
#########
