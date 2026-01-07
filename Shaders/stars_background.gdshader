shader_type canvas_item;

// Shader de partículas/estrelas flutuantes para background

uniform float star_density : hint_range(10.0, 200.0) = 80.0;
uniform float star_brightness : hint_range(0.0, 1.0) = 0.4;
uniform float twinkle_speed : hint_range(0.0, 5.0) = 1.0;
uniform vec4 star_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

float random(vec2 st) {
	return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
	// Usar a cor do vértice (ColorRect color) como base
	vec4 base = COLOR;
	vec2 uv = UV;
	
	// Grid de estrelas
	vec2 grid = floor(uv * star_density);
	vec2 f = fract(uv * star_density);
	
	float stars = 0.0;
	
	for(int y = -1; y <= 1; y++) {
		for(int x = -1; x <= 1; x++) {
			vec2 neighbor = vec2(float(x), float(y));
			vec2 cell = grid + neighbor;
			
			// Posição aleatória da estrela na célula
			vec2 point = vec2(random(cell), random(cell + 1.0));
			
			// Distância até a estrela
			float dist = length(f - neighbor - point);
			
			// Brilho com twinkle
			float twinkle = sin(TIME * twinkle_speed + random(cell) * 10.0) * 0.5 + 0.5;
			float star = smoothstep(0.1, 0.0, dist) * twinkle;
			
			// Só algumas células têm estrelas
			if (random(cell * 2.0) > 0.7) {
				stars += star;
			}
		}
	}
	
	// Aplicar estrelas
	vec3 final_color = base.rgb + star_color.rgb * stars * star_brightness;
	
	COLOR = vec4(final_color, base.a);
}
