local PublicTypes = require(script.Parent.PublicTypes)

export type ServerBridge<send> = PublicTypes.ServerBridge<send>
export type ClientBridge<send, receive> = PublicTypes.ClientBridge<send, receive>

return nil
