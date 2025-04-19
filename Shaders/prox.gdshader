shader_type spatial;

uniform vec3 charPos;
uniform float prox_thresh_1;
uniform float prox_thresh_2;

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
    
	if (chardistance < prox_thresh_1) {
		if (chardistance < prox_thresh_2) {
			ALBEDO *= vec3(1.0,0.25,0.25);
		}
		ALBEDO *= vec3(1.0,0.5,0.5);
	}
}