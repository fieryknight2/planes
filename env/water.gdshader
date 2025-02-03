shader_type canvas_item;

uniform float shift;
uniform float speed;
uniform float amplitude = 25.0;

void vertex() {
	// Called for every vertex the material is visible on.
	if (VERTEX.y < 0.0) {
		VERTEX.y += cos((TIME + VERTEX.x + shift) * speed) / speed * amplitude;
	}
}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
