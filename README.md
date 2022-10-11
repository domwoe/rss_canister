# Canister RSS Feed Example

Simple example of a canister that publishes an RSS feed.


## Live example

### Subscribe to feed

Go to https://vo3eu-eyaaa-aaaak-qawba-cai.raw.ic0.app and click on "Subscribe to feed".

The RSS Feed is available at https://vo3eu-eyaaa-aaaak-qawba-cai.raw.ic0.app/feed.rss

You can validate that the canister publishes a proper RSS feed with the [W3C Feed Validation Service](https://validator.w3.org/feed/check.cgi?url=https%3A%2F%2Fvo3eu-eyaaa-aaaak-qawba-cai.raw.ic0.app%2Ffeed.rss).


### Push item to feed

The canister exposes a function `add_item(item: FeedItem)` to push new items to the RSS feed.
You can use Candid UI to add a new item: https://a4gq6-oaaaa-aaaab-qaa4q-cai.raw.ic0.app/?id=vo3eu-eyaaa-aaaak-qawba-cai
