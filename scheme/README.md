# Schemes

The configuration provided with ANA (see ``ana.config``) is organized in a hierarchical structure,
that may consist of several configuration files. To allow validation, as well as (graphical) 
user-interface integration, configurations are accompanied by scheme files. 

*Note*:
In the following we will use the convention that optional configuration entries are displayed as ``[key]``.

## Format

### Top level format

Scheme files header is

    version: "<version-string>"

    [scheme]: <scheme-path>

Where the ``scheme-path`` defines the schemes identity. The identity is automatically generated based on the 
folder layout and may, therefore, be omitted.

The header is followed by the general definition for nodes below:

    [type]: <data-type>
    meta:
        <meta-information>
    [content]:
        <content definitions>

Schemes serve two purposes, either define the contents of a configuration file (see ''Configuration scheme format'') 
or as type declarations that can be imported (see ''Node format''). 

### Configuration scheme format

Schemes intended as the basis for configuration files have the following entries

    [type]: <content-type>
    meta:
        label: <scheme-short-label>
        [comment]: |
            <long description>
        [config]:
            file: <settings-file-path>
            [index]: <configuration-index>
            [ui]: <ui-component>
    [content]:
    <content-definition>

1. ``content type``:
    The content type is by default a ''dict'' (see below) and may be omitted.
2. ``config``
3. ``content``

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

