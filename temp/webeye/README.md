# Webeye

Webeye is doing webized reasoning via forward and backward chaining.
It participates in dialogues leading to necessary and sufficient answers, supported by proof steps, so that action can take place.

## Webized reasoning

[Webeye](https://github.com/IDLabResearch/Webeye) is using [ISO Prolog notation](https://en.wikipedia.org/wiki/Prolog#ISO_Prolog):

TERM            | Examples
----------------|---------
IRI             | `'http://example.org/etc#Socrates'`
VARIABLE        | `X` `_abc`
LITERAL         | `"abc"` `1.52` `1e-18` `pi` `dt("2022-01-15",'http://www.w3.org/2001/XMLSchema#date')`
LIST            | `[TERM,...]` `[TERM,...\|LIST]`
TRIPLE          | `IRI(TERM,TERM)`
GRAPH           | `TRIPLE,...`

CLAUSE          | Examples
----------------|---------
ASSERTION       | `TRIPLE.` `true => GRAPH.`
FORWARD_RULE    | `GRAPH => GRAPH.`
QUERY           | `GRAPH => true.`
ANSWER          | `GRAPH => true.`
INFERENCE_FUSE  | `GRAPH => false.`
BACKWARD_RULE   | `TRIPLE :- GRAPH,`[`PROLOG`](http://tau-prolog.org/documentation#prolog)`.`

Webeye performs forward chaining for a `FORWARD_RULE` and backward chaining for a `BACKWARD_RULE`.

Queries are posed and answered as `GRAPH => true.` so the answers are also queries be it with
some parts substituted and eventually containing more variables than in the original query.
This forms a dialogue leading to necessary and sufficient answers, supported by proof steps, so that action can take place.

Class membership is currently expressed as `class_iri(element_iri,class_iri)` with the assumption that an instance of
[rdfs:Class](https://www.w3.org/TR/rdf-schema/#ch_class) is a
[rdfs:subPropertyOf](https://www.w3.org/TR/rdf-schema/#ch_subpropertyof)
[rdf:type](https://www.w3.org/TR/rdf-schema/#ch_type).

## Installation and test

### Node

Install [Node.js](https://nodejs.org/en/download/) and then

```
$ git clone https://github.com/IDLabResearch/Webeye
$ cd Webeye
$ npm install tau-prolog
$ ./test_on_node
```

### Rust

Install [Rust](https://www.rust-lang.org/tools/install) and [Scryer Prolog](https://github.com/mthom/scryer-prolog#installing-scryer-prolog) `rebis-dev` branch and then

```
$ git clone https://github.com/IDLabResearch/Webeye
$ cd Webeye
$ ./test_on_rust
```

## Background

- Personal notes by Tim Berners-Lee: [Design Issues](https://www.w3.org/DesignIssues/)
- Book of Markus Triska: [The Power of Prolog](https://www.metalevel.at/prolog)
