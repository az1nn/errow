class_name CommunityAuthSession
extends RefCounted

signal auth_token_changed(token)

var auth_token := ""


func configure_from_environment() -> void:
	set_auth_token(OS.get_environment("ERROW_COMMUNITY_AUTH_TOKEN"))


func set_auth_token(token: String) -> void:
	var normalized := token.strip_edges()
	if auth_token == normalized:
		return
	auth_token = normalized
	auth_token_changed.emit(auth_token)


func clear() -> void:
	set_auth_token("")


func is_authenticated() -> bool:
	return not auth_token.is_empty()


func bearer_token() -> String:
	return auth_token
