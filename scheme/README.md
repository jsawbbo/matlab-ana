# Schemes

The configuration provided with ANA (see ''ana.config'') is organized in a hierarchical structure,
that may consist of several configuration files. To allow validation, as well as (graphical) 
user-interface integration, configurations are accompanied by scheme files. In addition to validation
this allows also to implement migration techniques.

## Format

The top-level entry of a scheme file consists of a version entry 

    version: "<version-string>"
    
Followed by the configuration structure.

There are three fundamental node types:
- **dict** (ana.config.node.dict), 
- **table** (ana.config.node.table), 
- **list** (ana.config.node.list), 
- **value** (ana.config.node.value).

Each node is described in the scheme file using:

    key: "key-name"
    type: <type-of-entry>
    meta:
        <meta information...>
    content:
        <content definition>

where <tt>meta</tt> is strictly optional. The entry <tt>content</tt>, though, depends on 
he node type. For **dict** and **table**, the same form as above is used. For **list**, 
only the type is given. A **value** does not have a content definition.

### Meta-information


### Values

The configuration is aware of the following types:

- **logical**
- **integral**
- **numeric**
- **string** 
- **time**
- **path**

...
