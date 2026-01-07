shader_type canvas_item;

// Shader de gradiente animado com glow para o card de novidades

uniform vec4 color1 : source_color = vec4(0.6, 0.1, 0.4, 1.0);
uniform vec4 color2 : source_color = vec4(0.3, 0.1, 0.5, 1.0);
uniform vec4 color3 : source_color = vec4(0.9, 0.3, 0.5, 1.0);
uniform float speed : hint_range(0.1, 3.0) = 0.5;
uniform float glow_intensity : hint_range(0.0, 2.0) = 0.3;

void fragment() {
	vec2 uv = UV;
	
	// Gradiente animado diagonal
	float t = TIME * speed;
	float gradient = sin(uv.x * 2.0 + uv.y * 1.5 + t) * 0.5 + 0.5;
	float gradient2 = cos(uv.x * 1.5 - uv.y * 2.0 + t * 0.7) * 0.5 + 0.5;
	
	// Mistura de cores
	vec4 col = mix(color1, color2, gradient);
	col = mix(col, color3, gradient2 * 0.3);
	
	// Efeito de brilho nas bordas
	float border_glow = 0.0;
	float edge_dist = min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y));
	border_glow = smoothstep(0.0, 0.15, edge_dist);
	border_glow = 1.0 - border_glow;
	
	// Pulso de glow
	float pulse = sin(TIME * 2.0) * 0.15 + 0.85;
	
	// Cor final com glow
	vec4 final_color = col;
	final_color.rgb += color3.rgb * border_glow * glow_intensity * pulse;
	
	// Aplicar ao texture original
	vec4 tex = texture(TEXTURE, UV);
	COLOR = mix(final_color, tex, tex.a);
	COLOR.a = 1.0;
}
