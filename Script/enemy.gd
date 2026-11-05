extends CharacterBody3D

@export var detect_range = 16.0
@export var lose_range = 16.0
@export var chase_speed = 3.0
@export var hop_height = 0.8
@export var hop_speed = 6.0
@export var jump_velocity = 6.4
@export var jump_trigger = 0.5 

@export var attack_range = 1.8
@export var attack_damage = 10
@export var attack_cooldown = 1.0

@onready var mesh = $MeshInstance3D
@onready var nav_agent = $NavigationAgent3D

var attack_timer = 0.0
var player = null
var isChasingPlayer = false
var hop_time = 0.0


func _ready():
	add_to_group("enemy")
	nav_agent.path_desired_distance = 0.3
	await get_tree().process_frame
	if get_tree().get_nodes_in_group("nav_region").size() == 0:
		bake_navmesh()

func bake_navmesh():
	var scene = get_tree().current_scene
	for node in scene.find_children("*", "CSGShape3D", true, false):
		node.add_to_group("nav_source")

	var navmesh = NavigationMesh.new()
	navmesh.agent_radius = 0.7
	navmesh.agent_height = 2.0
	navmesh.agent_max_climb = 1.6
	navmesh.geometry_source_geometry_mode = NavigationMesh.SOURCE_GEOMETRY_GROUPS_EXPLICIT
	navmesh.geometry_source_group_name = "nav_source"

	var source = NavigationMeshSourceGeometryData3D.new()
	NavigationServer3D.parse_source_geometry_data(navmesh, source, scene)
	NavigationServer3D.bake_from_source_geometry_data(navmesh, source)

	var region = NavigationRegion3D.new()
	region.navigation_mesh = navmesh
	region.add_to_group("nav_region")
	scene.add_child(region)



func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

	if player == null:
		player = get_tree().get_first_node_in_group("player")
		return

	var distance = global_position.distance_to(player.global_position)
	
	attack_timer = max(attack_timer - delta, 0.0)

	if distance <= detect_range and not isChasingPlayer:
		isChasingPlayer = true
		print("Enemy: CHASE")

	if distance > lose_range and isChasingPlayer:
		isChasingPlayer = false
		print("Enemy: IDLE")
		
	if isChasingPlayer:
		nav_agent.target_position = player.global_position
		var next_point = nav_agent.get_next_path_position()
		var direction = next_point - global_position
		var height_diff = direction.y 
		direction.y = 0
		direction = direction.normalized()
		velocity.x = direction.x * chase_speed
		velocity.z = direction.z * chase_speed
		
		if height_diff > jump_trigger and is_on_floor(): 
			velocity.y = jump_velocity 
		
		if distance <= attack_range and attack_timer <= 0.0:
			if player.has_method("take_damage"):
				player.take_damage(attack_damage)
				attack_timer = attack_cooldown
		
		hop_time += delta * hop_speed
		mesh.position.y = 1.0 + abs(sin(hop_time)) * hop_height
		nav_agent.target_position = player.global_position
		print(nav_agent.is_target_reachable())
	else:
		velocity.x = 0
		velocity.z = 0
		
		hop_time = 0.0
		mesh.position.y = 1.0
	move_and_slide()
