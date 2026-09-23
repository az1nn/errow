class_name CommunityAuthSession
extends RefCounted

var auth_token := ""


func configure_from_environment() -> void:
	set_auth_token(OS.get_environment("ERROW_COMMUNITY_AUTH_TOKEN"))


func set_auth_token(token: String) -> void:
	auth_token = token.strip_edges()


func clear() -> void:
	auth_token = ""


func is_authenticated() -> bool:
	return not auth_token.is_empty()


func bearer_token() -> String:
	return auth_token
