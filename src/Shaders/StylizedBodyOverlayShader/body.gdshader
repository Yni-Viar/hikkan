// Made by Yni, licensed under CC0

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform sampler2D body_part_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D face_part_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D outfit_part_albedo_1 : source_color, filter_linear_mipmap, repeat_enable, hint_default_black;
uniform sampler2D outfit_part_albedo_2 : source_color, filter_linear_mipmap, repeat_enable, hint_default_black;
uniform bool enable_face_emission = false;
//uniform sampler2D outfit_part_albedo_3 : source_color, filter_linear_mipmap, repeat_enable, hint_default_black;

uniform float roughness : hint_range(0.0, 1.0);

uniform float specular : hint_range(0.0, 1.0, 0.01);

void vertex() {

}

void fragment() {
	vec4 body_part_tex = texture(body_part_albedo, UV);
	vec3 result_tex = body_part_tex.rgb;
	vec4 face_part_tex = texture(face_part_albedo, UV);
	result_tex = mix(result_tex, face_part_tex.rgb, face_part_tex.a);
	body_part_tex = texture(outfit_part_albedo_1, UV);
	result_tex = mix(result_tex, body_part_tex.rgb, body_part_tex.a);
	body_part_tex = texture(outfit_part_albedo_2, UV);
	result_tex = mix(result_tex, body_part_tex.rgb, body_part_tex.a);
	//body_part_tex = texture(outfit_part_albedo_3, UV);
	//result_tex = mix(result_tex, body_part_tex.rgb, body_part_tex.a);
	ALBEDO = result_tex;
	SPECULAR = specular;
	ROUGHNESS = roughness;
	if (enable_face_emission)
	{
		EMISSION = face_part_tex.rgb;
	}
}
