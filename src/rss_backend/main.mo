import Array "mo:base/Array";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Time "mo:base/Time";

actor RssFeed {

  type FeedItem = {
    title : Text;
    description : Text;
  };

  type FeedItemWithTimestamp = {
    timestamp: Int;
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

  var maxFeedLength : Nat = 20;
  var emptyFeedItem = {
    timestamp = 0;
    title = "";
    description = "";
  };
  var feed : [var FeedItemWithTimestamp] = Array.init<FeedItemWithTimestamp>(maxFeedLength - 1, emptyFeedItem);
  var currentIndex : Nat = 0;

  var feedHeader : Text = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>" # "<rss version=\"2.0\" xmlns:atom=\"http://www.w3.org/2005/Atom\">" # "<channel>" # "<title>Canister Feed</title>" # "<link>https://" # MY_CANISTER_ID # ".raw.ic0.app</link>" # "<description>Example of an RSS feed served by a canister</description><atom:link href=\"https://" # MY_CANISTER_ID # ".raw.ic0.app/feed.rss\" rel=\"self\" type=\"application/rss+xml\" />";
  var feedEnd : Text = "</channel></rss>";

  public func add_item(it : FeedItem) {

    var item = {
      timestamp = Time.now();
      title = it.title;
      description = it.description;
    };

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
      
        var id = Principal.toText(Principal.fromActor(RssFeed));
    
        var feedHeader = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>" # "<rss version=\"2.0\" xmlns:atom=\"http://www.w3.org/2005/Atom\">" # "<channel>" # "<title>Canister Feed</title>" # "<link>https://" # id # ".raw.ic0.app</link>" # "<description>Example of an RSS feed served by a canister</description><atom:link href=\"https://" # id # ".raw.ic0.app/feed.rss\" rel=\"self\" type=\"application/rss+xml\" />";
        var feedEnd : Text = "</channel></rss>";

        var html: Text = "<html><head><title>Subscribe to Canister Feed</title></head><body><a href=\"https://" # id # ".raw.ic0.app/feed.rss\">Suscribe to canister feed</a></body></html>";
        {
          status_code = 200;
          headers = [("content-type", "text/html; charset=UTF-8")];
          body = Text.encodeUtf8(html);
        }

      };
      case ("GET", "/feed.rss") {

        var rssFeed : Text = feedHeader;

        for (item in Iter.fromArrayMut<FeedItemWithTimestamp>(feed)) {
          if (item.title != "") {
            var guid = 
            rssFeed := rssFeed # "<item><title>" # item.title # "</title><link>https://internetcomputer.org</link><description>" # item.description # "</description><guid isPermaLink=\"false\">" # Int.toText(item.timestamp) #"</guid></item>";
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
