---
sidebar_position: 2
---

# Logging network traffic

BridgeNet2's most powerful non-performance-related feature is logging. Logging can be enabled with a single line of code, anywhere. You can enable logging by setting the `Logging` property on any bridge to `true`, and disable logging by setting the `Logging` property to false. 

When you start logging a bridge, it will look like a little bit like this:

![image|690x89](https://devforum-uploads.s3.dualstack.us-east-2.amazonaws.com/uploads/original/5X/f/9/a/c/f9acd229d50af22ebc8785c272e70133e7b4bc12.png)

BridgeNet2 converts any passed argument into a string- including tables, and nested tables. BridgeNet2 will also count the number of bytes and appends it to the end of the log (thats the "(28B)" you see!). This is done using Pyseph's [RemotePacketSizeCounter](https://github.com/PysephWasntAvailable/RemotePacketSizeCounter) library.

### Log dumps

As of right now, log dumps are not a supported feature unfortunately. However, this will be coming in the future.