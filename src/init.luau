local RunService = game:GetService("RunService")

local clientActor = require("@src/initialization/clientActor")
local serverActor = require("@src/initialization/serverActor")
local clientSerial = require("@src/initialization/clientSerial")
local serverSerial = require("@src/initialization/serverSerial")

local threadContext: "actor" | "serial" = if script:GetActor() ~= nil then "actor" else "serial"
local runContext: "server" | "client" = if RunService:IsServer() then "server" else "client"

if threadContext == "actor" and runContext == "client" then
	clientActor()
elseif threadContext == "actor" and runContext == "server" then
	serverActor()
elseif threadContext == "serial" and runContext == "client" then
	clientSerial()
elseif threadContext == "serial" and runContext == "server" then
	serverSerial()
end

return {}
