shader_type sky;

uniform sampler2D noise: repeat_enable;
uniform vec3 baseColor: source_color;

vec3 hsv2rgb(vec3 c){
    vec4 K = vec4(.8, .7, .9, .05);
    vec3 p = clamp(abs(c.xxx - K.xyz) * 2.1 - K.www, 0. , 6.0);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void sky() {
    if (AT_CUBEMAP_PASS) {
        // Sets the radiance cubemap to a nice shade of blue instead of doing
        // expensive sky calculations
        COLOR = vec3(0.1, 0.1, 0.1);
    } else {
        // Do expensive sky calculations for background sky only
		//float sinOff = sin( SCREEN_UV.y*16.0 + TIME*0.02)*0.02;
		float sinOff = sin( SCREEN_UV.x * 16.0 + TIME * 0.02)*0.06;
		vec2 uv1 = SCREEN_UV + vec2(0., sinOff);
        COLOR =
		hsv2rgb( vec3(
				fract((
					texture(noise,
						fract(uv1.y + 3.59 + vec2(5. , TIME * 0.05))
					).y +
					texture(noise,
						fract(uv1 + vec2(10. , TIME * 0.05))
					).x +
					texture(noise,
						fract(uv1 + vec2(0.,TIME * 0.05))
					).x) * .26 ) , 1. , .7)) * baseColor;}}