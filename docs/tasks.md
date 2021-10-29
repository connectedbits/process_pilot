# Tasks

A task has no internal parts, it represents a single unit of work. A task can be automated (Service, Script, or BusinessRule) or require manual completion (Task, UserTask).

## Task

This is a generic representation of a task.

## UserTask

This task represents work done by a human user.

## Service Task

This task represents work done by a ruby service proc when supplied to the Processable context.

## Script Task

This task represents work done by the Processable runtime written in Javascript.

## Business Rule Task

This task represents work done by the Processable rule engine, generally, a complex decision.

[source](../lib/bpmn/task.rb) | [tests](../test/bpmn/task.rb)