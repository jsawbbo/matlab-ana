# Schemes

The configuration provided with ANA (see ''ana.config'') is organized in a hierarchical structure,
that may consist of several configuration files. To allow validation, as well as (graphical) 
user-interface integration, configurations are accompanied by scheme files. In addition to validation
this allows also to implement migration techniques.

## Format

The top-level entry of a scheme file consists of

    version: "<version-string>"
    
    key: "key-name"
    children:
        <list of sub-nodes>


FIXME


The configuration knows 4 fundamental types of configuration nodes or entries, respectively:
- **dictionaries** (ana.config.node.dict),
- **lists** (ana.config.node.list),
- **tables** (ana.config.node.table), and,
- **values** (ana.config.node.value).

Each of these entries may be described in the scheme file using:

    key: "key-name"
    type: type-of-entry
    meta:
        <meta information...>
    content:
        <list of sub-nodes>

where <tt>content</tt> may be omitted for values.

### Meta-information


### Values


