export type vector = Vector3

declare vector: {
	create: (x: number, y: number, z: number) -> vector,
	magnitude: (vec: vector | Vector3) -> number,
	normalize: (vec: vector | Vector3) -> vector,
	cross: (vec1: vector | Vector3, vec2: vector | Vector3) -> vector,
	dot: (vec1: vector | Vector3, vec2: vector | Vector3) -> number,
	angle: (vec1: vector | Vector3, vec2: vector | Vector3, axis: (vector | Vector3)?) -> number,
	floor: (vec: vector | Vector3) -> vector,
	ceil: (vec: vector | Vector3) -> vector,
	abs: (vec: vector | Vector3) -> vector,
	sign: (vec: vector | Vector3) -> vector,
	clamp: (vec: vector | Vector3, min: vector | Vector3, max: vector | Vector3) -> vector,
	max: (...vector) -> vector,
	min: (...vector) -> vector,
	
	zero: vector,
	one: vector,
}