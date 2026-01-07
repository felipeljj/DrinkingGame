shader_type canvas_item;

// Shader de borda com glow neon animado

uniform vec4 glow_color : source_color = vec4(1.0, 0.5, 0.2, 1.0);
uniform float glow_size : hint_range(0.0, 0.1) = 0.02;
uniform float glow_intensity : hint_range(0.0, 3.0) = 1.5;
uniform float pulse_speed : hint_range(0.0, 5.0) = 1.5;
uniform float corner_radius : hint_range(0.0, 0.5) = 0.1;

float rounded_box_sdf(vec2 p, vec2 b, float r) {
	vec2 q = abs(p) - b + r;
	return length(max(q, 0.0)) - r;
}

void fragment() {
	vec2 uv = UV * 2.0 - 1.0;
	vec2 size = vec2(1.0 - glow_size, 1.0 - glow_size);
	
	// Distância da borda arredondada
	float d = rounded_box_sdf(uv, size, corner_radius);
	
	// Glow com pulso
	float pulse = sin(TIME * pulse_speed) * 0.2 + 0.8;
	float glow = smoothstep(glow_size, 0.0, abs(d)) * glow_intensity * pulse;
	
	// Cor base (transparente no centro)
	vec4 base = texture(TEXTURE, UV);
	
	// Adicionar glow
	vec3 final_color = base.rgb + glow_color.rgb * glow;
	float final_alpha = max(base.a, glow * 0.5);
	
	COLOR = vec4(final_color, final_alpha);
}
