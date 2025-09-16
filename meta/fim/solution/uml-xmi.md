# XMI (XML Metadata Interchange)

## Description
Standards-based XML format for exchanging UML models and metamodels between modeling tools.
- [OMG XMI Specification](https://www.omg.org/spec/XMI)
- Version 2.5.1 (current stable)
- MOF-based metadata serialization

## Tools Supporting XMI
- **StarUML**: Full import/export support for XMI 2.1
- **Enterprise Architect**: Comprehensive XMI 1.0/2.1/2.5 support
- **IBM Rational Software Architect**: Native XMI interchange
- **MagicDraw**: XMI 2.5.1 with UML 2.5
- **Visual Paradigm**: XMI import/export with diagram layout
- **ArgoUML**: Open source with XMI 1.2 support
- **Eclipse UML2**: Reference implementation of UML2 metamodel

## Basic Class Model Structure
```xml
<xmi:XMI xmi:version="2.5" xmlns:xmi="http://www.omg.org/XMI" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:uml="http://www.eclipse.org/uml2/5.0.0/UML">
  <uml:Model xmi:id="model" name="MyModel">
    <packagedElement xmi:type="uml:Package" xmi:id="pkg" name="com.example">
      <packagedElement xmi:type="uml:Class" xmi:id="Class1" name="Customer">
        <ownedAttribute xmi:id="attr1" name="name" type="String"/>
        <ownedAttribute xmi:id="attr2" name="id" type="Integer"/>
        <ownedOperation xmi:id="op1" name="purchase"/>
      </packagedElement>
      <packagedElement xmi:type="uml:Association" xmi:id="assoc1">
        <memberEnd xmi:idref="Class1" xmi:idref="Class2"/>
      </packagedElement>
    </packagedElement>
  </uml:Model>
</xmi:XMI>
```

## Strengths
- **Tool Interoperability**: Exchange models between different UML tools
- **Complete UML Coverage**: Supports all UML diagram types and elements
- **Metamodel Support**: Can represent any MOF-compliant metamodel
- **Standards Compliance**: OMG standard ensures consistency
- **Round-trip Engineering**: Preserves model semantics during exchange

## Limitations
- **Verbose XML**: Large file sizes for complex models
- **Tool-specific Dialects**: Vendor extensions reduce portability
- **Diagram Layout Loss**: Visual positioning often not preserved
- **Version Incompatibility**: Different XMI versions cause issues
- **Performance**: Parsing large XMI files can be slow

## Best For
- **Model Exchange**: Sharing UML models between different tools
- **MDA (Model Driven Architecture)**: Foundation for model transformations
- **Model Repository**: Version control and model management
- **Tool Integration**: Connecting modeling tools in toolchains
- **Model Analysis**: Programmatic model inspection and metrics

## NPL-FIM Integration
```npl
fim:xmi[class-diagram] {
  source: "model.xmi"
  filter: "Package[@name='domain']"
  render: svg | interactive
}
```

XMI provides comprehensive UML model interchange with full metamodel support, ideal for tool integration and MDA workflows despite verbosity and dialect variations.