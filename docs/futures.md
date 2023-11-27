# Futures

This document describes possible future directions for this project.

## Input and output mappings

Input and output mappings are useful to transform data between process steps. For example, a process may need to call a service that expects a different data format than the process uses. Input and output mappings can be used to transform the data between the process and the service.

## Native support for FEEL and DMN logic

FEEL is a critical component of this engine. It's used to evaluate expressions and conditions. It's also used to evaluate DMN decisions. Currently, the engine uses a third-party library to evaluate FEEL expressions. This library is not actively maintained and has some limitations. It would be better to have a native implementation of FEEL and DMN logic.

## Complimentary modeling tool for BPMN, FEEL, and DMN

The BPMN, FEEL, and DMN modeling tools are all separate. It would be nice to have a single tool that can model all three. This would allow for a more seamless experience when modeling processes. Additionally, we can limit the BPMN modeling tool to only support the features that are supported by the engine. This would make it easier to model processes that can be executed by the engine.
