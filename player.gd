extends CharacterBody2D

const GRAVITY : int = 4200
const JUMP_SPEED : int = -1000

# called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	velocity.y += GRAVITY * delta
	if is_on_floor():
		if not get_parent().game_running: 
			$AnimatedSprite2D.play("idle")
		else: 
			if Input.is_action_just_pressed("ui_up"):
				velocity.y = JUMP_SPEED
				$AudioStreamPlayer.play() 
			else:
				$AnimatedSprite2D.play("run")
			
	else: 
		$AnimatedSprite2D.play("jump")
	
	move_and_slide()
		
