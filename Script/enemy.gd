extends CharacterBody3D

@export var detect_range = 8.0
@export var lose_range = 16.0
@export var chase_speed = 3.0
@export var hop_height = 0.3
@export var hop_speed = 6.0

@onready var mesh = $MeshInstance3D


var player = null
var isChasingPlayer = false
var hop_time = 0.0


func _ready():
	add_to_group("enemy")


func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()

	if player == null:
		player = get_tree().get_first_node_in_group("player")
		return

	var distance = global_position.distance_to(player.global_position)

	if distance <= detect_range and not isChasingPlayer:
		isChasingPlayer = true
		print("Enemy: CHASE")

	if distance > lose_range and isChasingPlayer:
		isChasingPlayer = false
		print("Enemy: IDLE")
		
	if isChasingPlayer:
		var direction = player.global_position - global_position
		direction.y = 0
		direction = direction.normalized()
		velocity.x = direction.x * chase_speed
		velocity.z = direction.z * chase_speed
		
		hop_time += delta * hop_speed
		mesh.position.y = 1.0 + abs(sin(hop_time)) * hop_height
	else:
		velocity.x = 0
		velocity.z = 0
		
		hop_time = 0.0
		mesh.position.y = 1.0
