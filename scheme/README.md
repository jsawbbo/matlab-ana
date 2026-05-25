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
- **list** (ana.config.node.list), 
- **value** (ana.config.node.value).

Each node is described in the scheme file using:

    key: "key-name"
    type: <type-of-entry>
    meta:
        <meta information...>
    content:
        <list of sub-nodes>

where <tt>content</tt> may be omitted for values.

### Meta-information


### Values


