shader_type canvas_item;

uniform bool flash;

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	
	if(flash) {
		col = vec4(1.0, 1.0, 1.0, col.a);
	}
	
	COLOR = col;
}