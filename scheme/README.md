# Schemes

The configuration provided with ANA (see ``ana.config``) is organized in a hierarchical structure,
that may consist of several configuration files. To allow validation, as well as (graphical) 
user-interface integration, configurations are accompanied by scheme files. 

*Note*:
In the following we will use the convention that optional configuration entries are displayed as ``[key]``.

## Format

### Top level format

The top-level entry of a scheme file consists of:

    version: "<version-string>"

    scheme: <scheme-path>
    meta:
        label: <scheme-short-label>
        [ui]: <ui-component>
        [comment]: |
            <long description>
    content:

The scheme path is organized similar to Matlab's configuration:

    /ana
        /dialog
        /storage

FIXME other...

### Node format
    
Each node is described in the scheme file using:

    -   key: "key-name"
        type: <node-type>
        meta:
            <meta information...>
        content:
        <content definition>

There are four fundamental node types:
- **dict** (ana.config.node.dict), 
- **table** (ana.config.node.table), 
- **list** (ana.config.node.list), 
- **leaf** (ana.config.node.leaf).

For **dict** and **table**, the same form as above is used:

    -   key: "key-name"
        type: dict
        meta:
            <meta information...>
        content:
        -   key: "key-name"
            type: <type-of-entry>
            meta:
                <meta information...>
            content:
            <content definition>
        ...

While **list** only has a scalar content (without a key):

    -   key: "key-name"
        type: list
        meta:
            <meta information...>
        content:
            type: <type-of-entry>
            meta:
                <meta information...>
            content:
            <content definition>

A **value** does not have a content definition.

### Meta-information

#### General

The ``meta`` field has the following format:

        meta:
            label: <short-label>
            comment: |
                <long-description>
            ...

Default values can be assigned with 

            default: <value>

or 

            default:
                eval: |
                    <script>

#### Rules for validation

FIXME

            rules:
                required: <boolean>
                <type-dependant rules>

The ``required`` entry is optional and ``false`` by default.

For type-dependant rules, see ``ana.config.node.validate`` for further information.

#### Actions

TODO 

            actions: 

### Values

The configuration is aware of the following types:

- **logical**
- **integral**
- **numeric**
- **string** 
- **datetime**
- **path**
- **url**

