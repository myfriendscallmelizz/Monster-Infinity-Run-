extends Node

#preload obstacles
var rock_scene = preload("res://rock.tscn")
var stone_scene = preload("res://stone.tscn")
var pebble_scene = preload("res://pebble.tscn")
var obstacle_types := [rock_scene, stone_scene, pebble_scene]
var obstacles : Array

#game variables
const PLAYER_START_POS := Vector2i(55, 302)
const CAM_START_POS := Vector2i(240, 190)
var difficulty
const MAX_DIFFICULTY : int = 2
var score : int
const SCORE_MODIFIER : int = 10
var high_score : int
var speed : float
const START_SPEED : float = 5
const MAX_SPEED : int = 15
const SPEED_MODIFIER : int = 5000
var screen_size : Vector2i
var ground_height : int
var game_running : bool
var last_obs

# Called when the node enters the scene tree for the first time.
func _ready(): 
	screen_size = get_window().size
	ground_height - $ground.get_node('Sprite2D').texture.get_height()
	$gameover.get_node('Button').pressed.connect(new_game)
	new_game()

func new_game(): 
	#reset variables
	score = 0
	show_score()
	game_running = false
	get_tree().paused = false
	difficulty = 0
	
	#delete all obstacles
	for obs in obstacles: 
		obs.queue_free()
	obstacles.clear()
	
	#reset the nodes
	$player.position = PLAYER_START_POS
	$player.velocity = Vector2i(0, 0)
	$Camera2D.position = CAM_START_POS
	$ground.position = Vector2i(0, -220)
	
	#reset hud and game over screen 
	$HUD.get_node("startlabel").show()
	$gameover.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if game_running:
		#speed up and adjust difficulty
		speed = START_SPEED + score / SPEED_MODIFIER 
		if speed > MAX_SPEED:
			speed = MAX_SPEED
		adjust_difficulty()
		
		#generate obstacles
		generate_obs()
		
		#move player and camera 
		$player.position.x += speed
		$Camera2D.position.x += speed
		
		#update score
		score += speed 
		show_score()
		
		#update ground position 
		if $Camera2D.position.x - $ground.position.x > screen_size.x * 1.5:
			$ground.position.x += screen_size.x
			
		#remove obstacles that have gone off screen
		for obs in obstacles: 
			if obs.position.x < ($Camera2D.position.x - screen_size.x):
				remove_obs(obs)
	else: 
		if Input.is_action_pressed("ui_accept"):
			game_running = true 
			$HUD.get_node("startlabel").hide()
		
func generate_obs():
	#generate ground obstacles
	if obstacles.is_empty() or last_obs.position.x < score + randi_range(300, 500):
		var obs_type = obstacle_types[randi() % obstacle_types.size()]
		var obs
		var max_obs = difficulty + 1
		for i in range(randi() % max_obs + 1): 
			obs = obs_type.instantiate()
			var obs_height = obs.get_node("Sprite2D").texture.get_height()
			var obs_scale = obs.get_node("Sprite2D").scale
			var obs_x : int = screen_size.x + score + 100 + (i * 100)
			var obs_y : int = screen_size.y - ground_height - (obs_height * obs_scale.y / 2) + 5
			last_obs = obs
			add_obs(obs, obs_x, obs_y)
	
func add_obs(obs, x, y): 
		obs.position = Vector2i(x, y)
		obs.body_entered.connect(hit_obs)
		add_child(obs)
		obstacles.append(obs)

func remove_obs(obs):
	obs.queue_free()
	obstacles.erase(obs)

func hit_obs(body):
	if body.name == "player":
		game_over()

func show_score():
	$HUD.get_node("scorelabel").text = "score:" + str(score / SCORE_MODIFIER)

func check_high_score():
	if score > high_score:
		high_score = score
		$HUD.get_node("highscorelabel").text = "HIGH SCORE: " + str(high_score / SCORE_MODIFIER)

func adjust_difficulty():
	difficulty = score / SPEED_MODIFIER
	if difficulty > MAX_DIFFICULTY:
		difficulty = MAX_DIFFICULTY

func game_over():
	check_high_score()
	get_tree().paused = true
	game_running = false
	$gameover.show()
