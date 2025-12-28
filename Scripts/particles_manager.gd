extends Node

# Singleton para gerenciar partículas reutilizáveis

func create_confetti(parent: Control, position: Vector2, color: Color = Color.WHITE, amount: int = 30):
	var particles = CPUParticles2D.new()
	particles.position = position
	particles.amount = amount
	particles.lifetime = 1.5
	particles.one_shot = true
	particles.explosiveness = 0.8
	particles.randomness = 0.5
	particles.z_index = 200
	
	# Propriedades de emissão
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 20.0
	
	# Direção e gravidade
	particles.direction = Vector2(0, -1)
	particles.spread = 180
	particles.gravity = Vector2(0, 300)
	particles.initial_velocity_min = 200
	particles.initial_velocity_max = 400
	
	# Visual
	particles.color = color
	particles.scale_amount_min = 8.0
	particles.scale_amount_max = 15.0
	
	parent.add_child(particles)
	particles.emitting = true
	
	# Remover após término
	await get_tree().create_timer(2.0).timeout
	if is_instance_valid(particles):
		particles.queue_free()

func create_bubble_particles(parent: Control) -> CPUParticles2D:
	var particles = CPUParticles2D.new()
	particles.amount = 20
	particles.lifetime = 8.0
	particles.preprocess = 2.0
	particles.explosiveness = 0.0
	particles.randomness = 0.3
	particles.z_index = -1
	
	# Emissão em linha na parte inferior
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	particles.emission_rect_extents = Vector2(540, 10)
	particles.position = Vector2(540, 1920)
	
	# Movimento pra cima
	particles.direction = Vector2(0, -1)
	particles.spread = 30
	particles.gravity = Vector2(0, -100)
	particles.initial_velocity_min = 50
	particles.initial_velocity_max = 150
	
	# Visual
	particles.color = Color(1, 1, 1, 0.3)
	particles.scale_amount_min = 10.0
	particles.scale_amount_max = 25.0
	
	# Fade out no final
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1, 1, 1, 0.3))
	gradient.add_point(1.0, Color(1, 1, 1, 0.0))
	particles.color_ramp = gradient
	
	parent.add_child(particles)
	particles.emitting = true
	
	return particles

func create_star_particles(parent: Control, position: Vector2, color: Color = Color(1, 0.843, 0, 1)):
	var particles = CPUParticles2D.new()
	particles.position = position
	particles.amount = 50
	particles.lifetime = 1.0
	particles.one_shot = true
	particles.explosiveness = 0.9
	particles.z_index = 200
	
	# Propriedades de emissão
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 10.0
	
	# Direção radial
	particles.direction = Vector2(0, -1)
	particles.spread = 180
	particles.gravity = Vector2(0, 0)
	particles.initial_velocity_min = 100
	particles.initial_velocity_max = 300
	particles.damping_min = 100
	particles.damping_max = 200
	
	# Visual
	particles.color = color
	particles.scale_amount_min = 5.0
	particles.scale_amount_max = 12.0
	
	# Fade out
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(color.r, color.g, color.b, 1.0))
	gradient.add_point(1.0, Color(color.r, color.g, color.b, 0.0))
	particles.color_ramp = gradient
	
	parent.add_child(particles)
	particles.emitting = true
	
	await get_tree().create_timer(1.5).timeout
	if is_instance_valid(particles):
		particles.queue_free()

func create_pulse_particles(parent: Control, position: Vector2, color: Color):
	var particles = CPUParticles2D.new()
	particles.position = position
	particles.amount = 15
	particles.lifetime = 0.8
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.z_index = 150
	
	# Círculo que expande
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 50.0
	
	particles.direction = Vector2(1, 0)
	particles.spread = 180
	particles.initial_velocity_min = 150
	particles.initial_velocity_max = 200
	
	particles.color = color
	particles.scale_amount_min = 15.0
	particles.scale_amount_max = 25.0
	
	# Fade out
	var gradient = Gradient.new()
	gradient.add_point(0.0, color)
	gradient.add_point(1.0, Color(color.r, color.g, color.b, 0.0))
	particles.color_ramp = gradient
	
	parent.add_child(particles)
	particles.emitting = true
	
	await get_tree().create_timer(1.0).timeout
	if is_instance_valid(particles):
		particles.queue_free()
