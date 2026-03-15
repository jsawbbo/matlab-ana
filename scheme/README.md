# Schemes

The configuration provided with ANA (see 'ana.config') FIXME


TODO:
- versioning (major change requires migration...)
- ???

## Format

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

### Top level entry


### Meta-information


### Values


