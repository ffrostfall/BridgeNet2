local errorStrings = {
	INSTANCE_NOT_FOUND = "couldn't find instances under replicatedstorage, waitforchild timeout hit",
	INSTANCE_NOT_VALID = "bridgenet2's internal instance tree wasnt valid, was it modified?",

	ID_PROPERTY_INCORRECT_TYPE = "identifier [%*] has an invalid attribute type, was it modified?",

	ACCESS_WITHOUT_INITIALIZATION = "function [%*] accessed without initialization",

	TREE_FAILURE = "tree failed to initialize: \n\t%*",
	SIGNAL_NOT_INITIALIZED = "tried to connect to event ID [%*], but it wasnt registered",

	PARALLEL_DISALLOWED = "cannot call function %* in parallel",

	ID_TIMEOUT_EXHAUSTED = "TODO error message",
}

local processed: { [any]: any } = {}
for errorName, errorText in pairs(errorStrings) do
	if errorName == "TREE_FAILURE" then
		processed[errorName] = errorText
		continue
	end

	processed[errorName] = `{errorText} [{errorName}]`
end

return {
	errors = processed :: typeof(errorStrings),
	logs = {
		SERIAL_LOADED = "v2.0.0 successfully loaded onto main thread",
	},
}
