class_name ChatMessage extends RefCounted

var sender_peer_id : int = -1
var sender_name : String
var message : String
var received_timestamp := Time.get_ticks_msec()

func is_internal() -> bool:
	return sender_peer_id == -1

func is_from_server() -> bool:
	return sender_peer_id == MultiplayerPeer.TARGET_PEER_SERVER

func is_from_myself(my_peer_id) -> bool:
	return sender_peer_id == my_peer_id
