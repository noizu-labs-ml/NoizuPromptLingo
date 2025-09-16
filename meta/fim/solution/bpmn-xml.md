# BPMN XML
Business Process Model and Notation XML format for executable process diagrams. [Docs](https://www.bpmn.org) | [Spec](https://www.omg.org/spec/BPMN/2.0.2/)

## Install/Setup
```bash
# bpmn-js for web visualization
npm install bpmn-js

# Camunda Modeler (desktop app)
# Download from https://camunda.com/download/modeler/

# Node.js parsing/manipulation
npm install bpmn-moddle
```

## Basic Usage
```xml
<?xml version="1.0" encoding="UTF-8"?>
<definitions xmlns="http://www.omg.org/spec/BPMN/20100524/MODEL"
             targetNamespace="http://example.com/bpmn">
  <process id="Process_1" isExecutable="true">
    <!-- Start Event -->
    <startEvent id="StartEvent_1" name="Order Received">
      <outgoing>Flow_1</outgoing>
    </startEvent>

    <!-- User Task -->
    <userTask id="Task_1" name="Process Order">
      <incoming>Flow_1</incoming>
      <outgoing>Flow_2</outgoing>
    </userTask>

    <!-- End Event -->
    <endEvent id="EndEvent_1" name="Order Complete">
      <incoming>Flow_2</incoming>
    </endEvent>

    <!-- Sequence Flows -->
    <sequenceFlow id="Flow_1" sourceRef="StartEvent_1" targetRef="Task_1"/>
    <sequenceFlow id="Flow_2" sourceRef="Task_1" targetRef="EndEvent_1"/>
  </process>
</definitions>
```

## Strengths
- Industry standard (OMG specification)
- Executable by BPMN engines (Camunda, Activiti, jBPM)
- Comprehensive process modeling semantics
- Supports complex workflows (gateways, subprocesses, events)
- Tool ecosystem for modeling and execution

## Limitations
- Verbose XML structure
- Complex for simple diagrams
- Requires specialized tools for editing
- Steep learning curve for full specification

## Best For
`business-processes`, `workflow-automation`, `enterprise-integration`, `compliance-documentation`, `executable-workflows`

## NPL-FIM Integration
```npl
@fim-render format=bpmn-xml engine=bpmn-js
  source: ./process.bpmn
  options:
    executable: true
    validate: strict
@end
```