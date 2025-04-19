shader_type spatial;
render_mode unshaded;

uniform vec3 charPos;
uniform float innerThresh;
uniform float outerThresh;

uniform vec3 edgecolor: source_color;

uniform sampler2D noise;
varying vec3 point;

void vertex() {
	point = (VIEW_MATRIX * vec4(charPos,1.0)).xyz;
}

void fragment() {
	float chardistance = length(
		point
		-
		VERTEX
	);
	
	float bright = 	(
		texture(noise, UV*15.+vec2(0.0,TIME*0.02)).x
		+ texture(noise, UV*7.+vec2(0.0,TIME*-0.03)).x
		)
		*0.5 - chardistance/innerThresh;
	
	chardistance += bright*.3;
	//ALBEDO = vec3(
		//1. - fract(chardistance/outerThresh)
	//);
	
	if (chardistance < outerThresh) {
	
		if (chardistance > innerThresh)
			ALBEDO = edgecolor;
	}
	else discard;
}