---
sidebar_position: 4
---

# Identifiers
A common pattern in Roblox are strings which represent something (e.g. a type of spell, a request to do something). Typically, this is bad- because you waste bandwidth sending over the *entire* string. If you send a shortened string that represents the full string, then you save on bandwidth. That is what the identifier system is- Identifier strings are 1-2 character strings that represent constant strings which you define.This saves on bandwith because sending shorter strings instead of longer strings saves on data. These are typically static, and can depict any string that does not change.

## Using identifiers
This library provides functionality to create identifiers without much interference in your code- the functions `ReferenceIdentifier`, `FromCompressed` and `FromIdentifier` are utility functions to create and read identifiers.