shader_type canvas_item;

uniform vec4 color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float width : hint_range(0, 10) = 1.0;
uniform int pattern : hint_range(0, 2) = 0; // 0 = Diamond, 1 = Circle, 2 = Square
uniform bool inside = false;
uniform bool add_margins = true; // Useful if your sprite touches the edge of the png

void vertex() {
	if (add_margins) {
		VERTEX += (UV * 2.0 - 1.0) * width;
	}
}

bool hasContraryNeighbour(vec2 uv, vec2 texture_pixel_size, sampler2D tex) {
	for (float i = -ceil(width); i <= ceil(width); i++) {
		float x = abs(i) > width ? width * sign(i) : i;
		float offset;
		
		if (pattern == 0) {
			offset = width - abs(x);
		} else if (pattern == 1) {
			offset = floor(sqrt(pow(width + 0.5, 2) - x * x));
		} else if (pattern == 2) {
			offset = width;
		}
		
		for (float j = -ceil(offset); j <= ceil(offset); j++) {
			float y = abs(j) > offset ? offset * sign(j) : j;
			vec2 xy = uv + texture_pixel_size * vec2(x, y);
			
			if ((xy != clamp(xy, vec2(0.0), vec2(1.0)) || texture(tex, xy).a <= 0.0) == inside) {
				return true;
			}
		}
	}
	
	return false;
}

void fragment() {
	vec2 uv = UV;
	
	if (add_margins) {
		uv -= (uv * 2.0 - 1.0) * (width / (1.0 / TEXTURE_PIXEL_SIZE));
		uv = clamp(uv, vec2(0.0), vec2(1.0)); // Prevent texture repeating artifacts
	}
	
	vec4 texture_color = texture(TEXTURE, uv);
	
	if ((texture_color.a > 0.0) == inside && hasContraryNeighbour(uv, TEXTURE_PIXEL_SIZE, TEXTURE)) {
		texture_color.rgb = inside ? mix(texture_color.rgb, color.rgb, color.a) : color.rgb;
		texture_color.a += (1.0 - texture_color.a) * color.a;
	}
	
	COLOR = texture_color;
}