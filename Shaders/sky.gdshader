shader_type sky;

uniform sampler2D noise: repeat_enable;
uniform vec3 baseColor: source_color;

vec3 hsv2rgb(vec3 c){
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void sky() {
    if (AT_CUBEMAP_PASS) {
        // Sets the radiance cubemap to a nice shade of blue instead of doing
        // expensive sky calculations
        COLOR = vec3(0.1, 0.1, 0.1);
    } else {
        // Do expensive sky calculations for background sky only
		float sinOff = sin(
			SCREEN_UV.y*16. + TIME*0.02
			)*0.02;
		vec2 uv1 = SCREEN_UV + vec2(sinOff, 0.0);
        COLOR = 
		hsv2rgb(
			vec3(
				fract((
					texture(noise,
						fract(uv1*.9 + vec2(TIME*0.05,0.))
					).x +
					texture(noise,
						fract(uv1 + vec2(TIME*-0.03,0.))
					).x
				)
				*0.5)
				,
				1.0, .5)
			) * baseColor
			;
    }
}