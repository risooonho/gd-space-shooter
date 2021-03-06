extends RigidBody2D

#ENUMS
enum SIZE {BIG, MEDIUM, SMALL}

#SCRIPTS
const Bullet = preload("res://Scripts/Bullet.gd")

#SCENES
export (PackedScene) var medium_meteor_scene
export (PackedScene) var small_meteor_scene
export (PackedScene) var explosion
export (PackedScene) var info_text

#EXPORT
export (SIZE) var size
export (int) var points

#VARS
var speed = Vector2(0, 0)
var meteor_manager = null

func _ready():
	speed.x = randi() % 10 - 5
	speed.y = randi() % 10 - 5
	apply_impulse(Vector2(0, 0), speed*75)
	contact_monitor = true
	contacts_reported = 10

func setup(pos, meteor_mgr, dist = 0):
	self.meteor_manager = meteor_mgr
	self.meteor_manager.add_meteor(self)
	position = pos
	rotation_degrees = randi() % 360
	move_local_y(-dist)

func _on_meteor_body_entered(body):
	if body is Bullet && size == SIZE.BIG:
		explode()
		shatter_to_pieces()
	
	elif body is Bullet:
		explode()

func _create_info(info, color):
	var new_info_text = info_text.instance()
	new_info_text.setup(info, position, color)
	get_parent().add_child(new_info_text)
	
func shatter_to_pieces():
	var medium_meteor = medium_meteor_scene.instance()
	var medium_meteor2 = medium_meteor_scene.instance()
	var small_meteor = small_meteor_scene.instance()
	
	var meteors = [medium_meteor, medium_meteor2, small_meteor]
	
	for meteor in meteors:
		meteor.setup(position, meteor_manager)
		get_parent().call_deferred("add_child", meteor)

func destroy():
	meteor_manager.remove_meteor(self)
	queue_free()

func explode():
	get_parent().find_node("player").add_score(points)
	_create_info("+ " + str(points) + "P", Color(0,1,0))
	var new_explosion = explosion.instance()
	new_explosion.setup(position)
	get_parent().add_child(new_explosion)
	destroy()
