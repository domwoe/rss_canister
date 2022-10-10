import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Text "mo:base/Text";

actor {

  type FeedItem = {
    title : Text;
    description : Text;
  };

  type HeaderField = (Text, Text);

  type HttpResponse = {
    status_code : Nat16;
    headers : [HeaderField];
    body : Blob;
  };

  type HttpRequest = {
    method : Text;
    url : Text;
    headers : [HeaderField];
    body : Blob;
  };

  var MY_CANISTER_ID: Text = "vo3eu-eyaaa-aaaak-qawba-cai";

  var maxFeedLength : Nat = 20;
  var emptyFeedItem = {
    title = "";
    description = "";
  };
  var feed : [var FeedItem] = Array.init<FeedItem>(maxFeedLength - 1, emptyFeedItem);
  var currentIndex : Nat = 0;

  var feedHeader : Text = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>" # "<rss version=\"2.0\">" # "<channel>" # "<title>Canister Feed</title>" # "<link>https://" # MY_CANISTER_ID # ".raw.ic0.app</link>" # "<description>Example of an RSS feed served by a canister</description><atom:link href=\"https://" # MY_CANISTER_ID # ".raw.ic0.app/feed.rss\" rel=\"self\" type=\"application/rss+xml\" />";
  var feedEnd : Text = "</channel></rss>";

  public func add_item(item : FeedItem) {
    feed[currentIndex] := item;

    if (currentIndex < maxFeedLength - 1) {
      currentIndex += 1;
    } else {
      currentIndex := 0;
    }

  };

  public query func http_request(req : HttpRequest) : async HttpResponse {
    let ?path = Text.split(req.url, #char '?').next();
    switch (req.method, path) {
      case ("GET", "/") {

        var html: Text = "<html><head><title>Subscribe to Canister Feed</title></head><body><a href=\"https://" # MY_CANISTER_ID # ".raw.ic0.app/feed.rss\">Suscribe to canister feed</a></body></html>";
        {
          status_code = 200;
          headers = [("content-type", "text/html; charset=UTF-8")];
          body = Text.encodeUtf8(html);
        }

      };
      case ("GET", "/feed.rss") {

        var rssFeed : Text = feedHeader;

        for (item in Iter.fromArrayMut<FeedItem>(feed)) {
          if (item.title != "") {
            rssFeed := rssFeed # "<item><title>" # item.title # "</title><link>https://internetcomputer.org</link><description>" # item.description # "</description></item>";
          };
        };

        rssFeed := rssFeed # feedEnd;

        {
          status_code = 200;
          headers = [("content-type", "application/rss+xml")];
          body = Text.encodeUtf8(rssFeed);
        }

      };
      case _ {
        {
          status_code = 400;
          headers = [];
          body = "Invalid request";
        };
      };
    };

  };
};
