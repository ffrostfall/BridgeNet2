export type Profiler = { Begin: (label: string) -> (), stop: () -> () }

local function create_bench<T...>(
	parameter_generator: () -> T...,
	bench_table: {
		[string]: (profiler: Profiler, T...) -> (),
	}
): any
	return {
		Functions = bench_table,
		ParameterGenerator = parameter_generator,
	}
end

return create_bench
