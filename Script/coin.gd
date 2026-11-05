extends Area3D


@export var item_id: String = ""
@export var spin_speed: float = 2.0

var collected: bool = false


func _ready() -> void:
	add_to_group("pickup")
	if item_id == "":
		item_id = name
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	if not collected:
		rotate_y(spin_speed * delta)


func _on_body_entered(body: Node3D) -> void:
	if collected:
		return
	if body.is_in_group("player"):
		body.collect_item(item_id)
		set_collected(true)
		$AudioStreamPlayer3D.play()


func set_collected(value: bool) -> void:
	collected = value
	visible = not value
	# Deferred karena collision tidak boleh diubah langsung di dalam callback physics
	$CollisionShape3D.set_deferred("disabled", value)
