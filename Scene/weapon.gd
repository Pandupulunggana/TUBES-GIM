extends Node3D

@export var damage := 10

func _ready():
	$Hitbox.monitoring = false
	$Hitbox.body_entered.connect(_on_hit)

func attack():
	await get_tree().create_timer(0.25).timeout
	$Hitbox.monitoring = true
	await get_tree().create_timer(0.5).timeout
	$Hitbox.monitoring = false
	
func _on_hit(body):
	if body.is_in_group("enemy") and body.has_method("take_damage"):
		body.take_damage(damage)
