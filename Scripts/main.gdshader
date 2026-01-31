shader_type canvas_item;

// ===== Balatro-style animated background (Godot 4 fixed) =====

uniform float spin_rotation_speed = 2.0;
uniform float move_speed = 7.0;
uniform vec2 offset = vec2(0.0, 0.0);

uniform vec4 colour_1 : source_color = vec4(0.871, 0.267, 0.231, 1.0);
uniform vec4 colour_2 : source_color = vec4(0.0, 0.42, 0.706, 1.0);
uniform vec4 colour_3 : source_color = vec4(0.086, 0.137, 0.145, 1.0);

uniform float contrast = 3.5;
uniform float lighting = 0.4;
uniform float spin_amount = 0.25;
uniform float pixel_filter = 740.0;
uniform bool is_rotating = true;

#define SPIN_EASE 1.0

vec4 effect(vec2 screen_size, vec2 screen_uv) {
	
	float pixel_size = length(screen_size) / pixel_filter;
	
	vec2 uv = (floor(screen_uv * (1.0 / pixel_size)) * pixel_size
		- 0.5 * screen_size) / length(screen_size) - offset;
	
	float uv_len = length(uv);
	
	float speed = spin_rotation_speed * SPIN_EASE * 0.2;
	if (is_rotating) {
		speed *= TIME;
	}
	speed += 302.2;
	
	float angle = atan(uv.y, uv.x)
		+ speed
		- SPIN_EASE * 20.0 * (spin_amount * uv_len + (1.0 - spin_amount));
		
	vec2 mid = (screen_size / length(screen_size)) * 0.5;
	uv = vec2(
		uv_len * cos(angle),
		uv_len * sin(angle)
	) - mid;
	uv *= 30.0;
	speed = TIME * move_speed;
	
	vec2 uv2 = vec2(uv.x + uv.y, uv.x + uv.y);
	
	for (int i = 0; i < 5; i++) {
		uv2 += sin(max(uv.x, uv.y)) + uv;
		uv += 0.5 * vec2(
			cos(5.1123314 + 0.353 * uv2.y + speed * 0.131121),
			sin(uv2.x - 0.113 * speed)
		);
		uv -= vec2(
			cos(uv.x + uv.y),
			sin(uv.x * 0.711 - uv.y)
		);
	}
	
	float contrast_mod = (0.25 * contrast + 0.5 * spin_amount + 1.2);
	float paint_res = clamp(length(uv) * 0.035 * contrast_mod, 0.0, 2.0);
	
	float c1p = max(0.0, 1.0 - contrast_mod * abs(1.0 - paint_res));
	float c2p = max(0.0, 1.0 - contrast_mod * abs(paint_res));
	float c3p = 1.0 - min(1.0, c1p + c2p);

	float light =
		(lighting - 0.2) * max(c1p * 5.0 - 4.0, 0.0) +
		lighting * max(c2p * 5.0 - 4.0, 0.0);

	vec4 col =
		(0.3 / contrast) * colour_1 +
		(1.0 - 0.3 / contrast) *
		(colour_1 * c1p +
		 colour_2 * c2p +
		 vec4(colour_3.rgb * c3p, colour_1.a * c3p))
		+ light;
	return col;
}

void fragment() {
	vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE;
	vec2 screen_uv = SCREEN_UV * screen_size;
	COLOR = effect(screen_size, screen_uv);
}