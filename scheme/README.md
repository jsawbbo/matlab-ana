# Schemes

The configuration provided with ANA (see ``ana.config``) is organized in a hierarchical structure,
that may consist of several configuration files. To allow validation, as well as (graphical) 
user-interface integration, configurations are accompanied by scheme files. 

*Note*:
Throughout this document, optional configuration entries are denoted by ``[key]``.

## Format

### Overview

A scheme file begins with the following header:

    version: "<version-string>"
    [index]: <branch-index>

The ``branch-index`` specifies the location of the branch within the scheme and configuration hierarchy. 
It takes the  form of a path (e.g., /ana/storage). If omitted, the index is automatically derived from 
the location of the scheme file within the directory hierarchy.

It is followed by the body that depends on the kind of the scheme, which is either a
1. ``branch scheme`` - defining a node in the scheme hierarchy, without describing data,
2. ``type scheme`` - defining a reusable data structure, including validation rules, or,
3. ``configuration scheme`` - defining a persistent configuration based on a particular structure.

#### Branch schemes

The minimal body of a branch scheme is

    [key]: <navigation-key>
    meta:
        label: <label>
        [comment]: |
            <long description>
        [visibility]: <visibility-function>

The ``key`` refers to the navigational path in the configuration tree. By default it is identical to the 
scheme path and can be omitted.

The ``meta`` information — as with any node in the scheme — is used for display purposes.

Note: A branch scheme may not describe configuration data. The ``type`` field, present in the other scheme
formats, must not be used.

#### Type schemes

Type schemes follow the same semantics as the content (see below). The format is

    type: <data-type>
    meta:
        <meta-information>
    [content]:
    <content-definition>

Note: The top-level key is meaningful only for branch and configuration schemes. It is ignored in type schemes.

For further information, see ''Content'' below.

#### Configuration schemes

Configuration schemes refer to an actual configuration file. In addition to the content (see below), the top-level definition also
contains the ``config`` entry:

    [key]: <navigation-key>
    type: <data-type>
    meta:
        <meta-information>
    config:
        [file]: <config-file>
        [ui]:
            <user-interface-definition>
    [content]:
    <content-definition>

The ``config.file`` entry sets the filename. By default it is created from the navigation key under the default
configuration save path (see ``ana.os.paths()``). Project configurations may instead use a settings path within 
the project tree, for example "{project}/settings/config.yml".

TODO: key vs. file location persistence vs. expected sorting order (accessing ana.storage.cachedir should somehow be reflected in the config file path...)

The user interface definition is the form:

        ui:
            component: <page-component>

where the component can be loaded with ana.config.ui as a configuration page. If a dedicated component is not
provided, a generic editor will be used.

### Node format
    
Each configuration node is described in list form under ``content`` as:

    -   key: <node-key>
        type: <node-type>
        meta:
            <meta information...>
        content:
        <content definition>

The ``node key`` is a single word. Both navigation paths and node keys appear in the configuration (see e.g. ``ana.config.file``) 
as structure-like keys. It is recommended to use Matlab identifiers.

There are thre fundamental branch types:
- **dict** (ana.config.node.dict), 
- **table** (ana.config.node.table), 
- **list** (ana.config.node.list), and,

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

**Leaf nodes** are described by

    -   key: "key-name"
        type: <leaf-type>
        meta:
            <meta information...>

Know leaf types are:
- **logical** (``true`` or ``false``),
- **integral** (integer-valued numbers in general),
- **numeric** (floating-point numbers),
- **string** (strings),
- **datetime** (see ``ana.type.datetime``),
- **path** (see ``ana.fs.path``), and,
- **url** (see ``ana.type.url``).

### Imported types

Common node types may also be defined in "type schemes" (see above). They can be imported using

    -   key: "key-name"
        import: <scheme-path>
        [meta]:
            <meta information...>

Note: 
- type, content, and meta.rules cannot be overridden.
- meta.label, meta.comment, and meta.default can be overridden.
- Imported schemes never cause configuration files to be loaded.

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

TODO: I need to be able to use also YAML for populating a whole config (e.g. the roles in a project).
      ->
            default:
                [eval]: |
                    <script>
                [import]: <yaml-file>
                [value]: <default-value>

#### Rules for validation

The general format for validation rules is:

            rules:
                required: <boolean>
                <type-dependant rules>

The ``required`` entry is optional and ``false`` by default.

For type-dependant rules, see ``ana.config.node.validate`` for further information.

#### Visibility

FIXME 

            [visibility]: <visibility-function>