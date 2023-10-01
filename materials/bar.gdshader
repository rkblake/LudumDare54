shader_type canvas_item;

uniform float amount : hint_range(0.0, 1.0);
//uniform vec2 resolution;
uniform vec4 color : hint_color;

void fragment() {
	vec2 st = FRAGCOORD.xy/TEXTURE_PIXEL_SIZE.xy;

//	float l = step(0.1, st.x);
//	float t = step(0.1, UV.y);
//	float b = step(0.1, 1.0-UV.y);
//	float r = step(0.1, 1.0-UV.x);
	float l = step(amount, UV.x);

	COLOR = mix(color, vec4(0.0), l);
}
