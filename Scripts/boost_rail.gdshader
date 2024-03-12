shader_type canvas_item;

uniform sampler2D texturey : repeat_enable;
uniform sampler2D edgefuzz;
uniform vec2 direction = vec2(0.0, 1);
uniform vec2 direction2 = vec2(0.0, 1);
uniform vec2 speedyrection = vec2(2, 0);
uniform vec4 transparency = vec4(1.0, 1.0, 1.0, 0.3);

void fragment() {
	COLOR = texture(TEXTURE, UV+TIME*direction)*texture(TEXTURE, UV+TIME*direction2)*texture(texturey, UV+TIME*speedyrection)*transparency;
	//COLOR = texture(edgefuzz, UV*vec2(1, -.5));
}