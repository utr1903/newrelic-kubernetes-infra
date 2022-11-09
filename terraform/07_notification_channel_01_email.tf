############################
### Notification Channel ###
############################

# Notification destination - Email
resource "newrelic_notification_destination" "email" {
  for_each = {
    for email in local.emails : email.name => email.email
  }

  name       = each.key
  account_id = var.NEW_RELIC_ACCOUNT_ID
  type       = "EMAIL"

  property {
    key   = "email"
    value = each.value
  }
}

# Notification channel - Email
resource "newrelic_notification_channel" "email" {
  for_each = {
    for email in local.emails : email.name => email.email
  }

  name       = each.key
  account_id = var.NEW_RELIC_ACCOUNT_ID
  type       = "EMAIL"

  destination_id = newrelic_notification_destination.email[each.key].id
  product        = "IINT"

  property {
    key   = "subject"
    value = "Alert - ${each.key}"
  }
}
#########
