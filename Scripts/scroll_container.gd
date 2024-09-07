extends ScrollContainer

@export var button_scene : PackedScene

var touch_start_position : Vector2
var touch_movement_threshold : float = 10.0  # Limiar para diferenciar entre toque e rolagem

func _ready():
	pass

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_start_position = event.position
		else:
			var touch_end_position = event.position
			var distance_moved = touch_end_position.distance_to(touch_start_position)
			
			if distance_moved < touch_movement_threshold:
				# Considera como um clique, adicione sua lógica de clique aqui
				_handle_click(event)
			else:
				# Considera como uma rolagem, pode adicionar lógica para tratar rolagem se necessário
				_handle_scroll(event)
				
func _handle_click(event):
	# Aqui você pode implementar a lógica para lidar com cliques
	print("Clique detectado em: ", event.position)

func _handle_scroll(event):
	# Aqui você pode adicionar lógica para lidar com rolagens, se necessário
	pass
