//shader_type canvas_item;
//
//void vertex() {
	//// Called for every vertex the material is visible on.
//}
//
//void fragment() {
	//// Called for every pixel the material is visible on.
//}
//
////void light() {
////	// Called for every pixel for every light affecting the CanvasItem.
////	// Uncomment to replace the default light processing function with this one.
////}

shader_type canvas_item;

uniform float speed = 0.5;
uniform float density = 10.0;
uniform float spiral_strength = 2.0;
uniform vec4 color_dark : source_color = vec4(0.05, 0.05, 0.05, 1.0);
uniform vec4 color_light : source_color = vec4(0.68, 0.69, 0.71, 1.0);

// Simple noise function to create the "scratchy" hand-drawn texture
float noise(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    // Center the coordinates (-0.5 to 0.5)
    vec2 uv = UV - 0.5;
    
    // Convert to polar coordinates
    float angle = atan(uv.y, uv.x);
    float radius = length(uv);
    
    // Create the spiral movement
    // The "spiral_strength" adds the curve, "TIME * speed" makes it spin
    float spiral = sin(radius * density - angle * spiral_strength + TIME * speed);
    
    // Add "scratchy" texture using noise
    float scratch = noise(uv + TIME * 0.01);
    float final_pattern = smoothstep(0.2, 0.8, spiral + scratch * 0.4);
    
    // Mix the monochrome colors based on the spiral pattern
    // We darken the center to give it depth
    vec4 final_color = mix(color_dark, color_light, final_pattern * radius * 2.0);
    
    COLOR = final_color;
}