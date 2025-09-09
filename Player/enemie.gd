extends CharacterBody2D

var enemy_death_effect = preload("res://enemydeatheffect.tscn")
var healh_amount : int = 3
var direction = 1
const  speed = 100
var health_amount : int = 3

@onready var ray_cast_right = $"RayCast Right"
@onready var ray_cast_left = $"RayCast Left"
@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta):
	if ray_cast_right.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
	if ray_cast_left.is_colliding():
		direction = 1
		animated_sprite.flip_h = false
		
	position.x += direction * speed * delta
		
		
func _on_hurtbox_area_entered(area : Area2D):
	print("hurtbox area entered")
	if area.get_parent().has_method("get_damage_amount"):
		var node = area.get_parent() as Node
		health_amount -= node.damage_amount
		print("health amount: ", health_amount)
		
	if health_amount <= 0:
		var enemy_death_effect_instance = enemy_death_effect.instantiate() as Node
		enemy_death_effect_instance.global_position = global_position
		get_parent().add_child(enemy_death_effect_instance)
		queue_free()
