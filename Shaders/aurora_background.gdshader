shader_type canvas_item;

// Warm palette
uniform vec4 bg_color : source_color = vec4(0.05, 0.02, 0.01, 1.0); // Deep warm black
uniform vec4 color1 : source_color = vec4(0.8, 0.3, 0.0, 1.0); // Burnt Orange
uniform vec4 color2 : source_color = vec4(1.0, 0.7, 0.1, 1.0); // Gold
uniform vec4 color3 : source_color = vec4(0.5, 0.1, 0.0, 1.0); // Deep Red/Brown

uniform float speed = 0.15; // Slow movement
uniform float density = 1.5; // Size of patches

// Gradient Noise 2D
vec2 hash(vec2 p) {
    p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
    return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(dot(hash(i + vec2(0.0, 0.0)), f - vec2(0.0, 0.0)),
                   dot(hash(i + vec2(1.0, 0.0)), f - vec2(1.0, 0.0)), u.x),
               mix(dot(hash(i + vec2(0.0, 1.0)), f - vec2(0.0, 1.0)),
                   dot(hash(i + vec2(1.0, 1.0)), f - vec2(1.0, 1.0)), u.x), u.y);
}

void fragment() {
    vec2 uv = UV;
    float t = TIME * speed;
    
    // Create layered movement
    float n1 = noise(uv * density + vec2(t, t * 0.5));
    float n2 = noise(uv * density * 1.5 - vec2(t * 0.7, t * 0.2));
    float n3 = noise(uv * density * 2.0 + vec2(-t * 0.5, t * 0.8));
    
    // Combine noise layers for organic feel
    float movement = n1 * 0.5 + n2 * 0.3 + n3 * 0.2;
    
    // Remap to 0-1 range and add softness
    float intensity = smoothstep(0.2, 0.8, movement * 0.5 + 0.5);
    
    // Color mixing
    vec3 mixed_color = mix(color1.rgb, color2.rgb, intensity);
    mixed_color = mix(mixed_color, color3.rgb, sin(uv.x * 3.0 + t) * 0.5 + 0.5);
    
    // Apply intensity to make it subtle distinct lights
    // The "less" part: multiply by a low factor so it blends mostly with BG
    vec3 final = mix(bg_color.rgb, mixed_color, intensity * 0.4); 
    
    // Enhance brightness slightly in "hot" spots
    final += mixed_color * smoothstep(0.6, 1.0, intensity) * 0.2;
    
    // Vignette
    float dist = distance(uv, vec2(0.5));
    final *= 1.0 - dist * 0.5;

    COLOR = vec4(final, 1.0);
}
