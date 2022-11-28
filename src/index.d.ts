interface ClientProcess {
    _addToQueue<T>(identifier: string, object: T): void
    _connect<T>(identifier: string, object: (T) => void): void
}

interface Identifiers {
    ReferenceIdentifier(name: string, maxWaitTime: number | undefined): string
    FromCompressed(identifier: string): string | undefined
    FromIdentifier(identifier: string): string | undefined
}

interface BridgeNet2 {
    // Identifiers.luau
    ReferenceIdentifier(name: string, maxWaitTime: number | undefined): string
    FromCompressed(identifier: string): string | undefined
    FromIdentifier(identifier: string): string | undefined

    // NetworkUtils.luau
    FromHex(hex: string): string
    ToHex(reg: string): string
    NumberToBestForm(num: number): number | string
    CreateUUID(): string
}

export default BridgeNet2