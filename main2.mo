import List "mo:base/List";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Prim "mo:⛔";

actor {
  
  public type Message = {
    content : Text;
    time : Time.Time;
  };

  public type Microblog = actor {
    follow: shared (Principal) -> async();
    follows: shared query () -> async [Principal];
    post: shared (Text) -> async ();
    posts: shared query (Time.Time) -> async [Message];
    timeline: shared (Time.Time) -> async [Message];
  };
  
  var followed : List.List<Principal> = List.nil();

  public shared func follow(id:Principal) : async () {
    followed := List.push(id,followed);
  };

  public shared query func follows() : async [Principal] {
    List.toArray(followed)
  };

  var messages : List.List<Message> = List.nil();

  public shared (msg) func post(text:Text) : async () {
    //assert(Principal.toText(msg.caller) == "bjqgs-d3bmy-qpvvu-pryxo-67xmq-nytpr-cxhps-ztrtm-m3hem-2focw-lqe");
    let msg ={
      content = text;
      time = Time.now();
    };
    messages := List.push(msg,messages);
  };

  public shared query func posts(since: Time.Time) : async [Message] {
    var msg2 : List.List<Message> = List.nil();
    for (msg in Iter.fromList(messages)){
      if (msg.time >= since){
        msg2 :=List.push(msg,msg2);
      };
    };
    List.toArray(msg2);
  };

  public shared func timeline(since: Time.Time) : async [Message] {
    var all : List.List<Message> = List.nil();

    for (id in Iter.fromList(followed)){
      let canister : Microblog = actor(Principal.toText(id));
      let msgs = await canister.posts(since);
      for (msg in Iter.fromArray(msgs)){
        all :=List.push(msg,all)
      }
    };

    List.toArray(all);
  };


};
