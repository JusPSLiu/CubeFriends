shader_type canvas_item;

uniform sampler2D texture;
uniform vec2 direction = vec2(0.0, 1);
uniform vec4 transparency = vec4(1.0, 1.0, 1.0, 0.3);

void fragment() {
	COLOR = texture(TEXTURE, UV+TIME*direction)*transparency;
}