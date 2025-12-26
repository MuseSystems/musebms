+++
title = "Technical Documentation"
linkTitle = "Technical"
description = """
Database and application server technical documentation for developers of the software.
"""

draft = false

[menu.main]
weight = 40
pre = "<i class='fa-solid fa-book'></i>"

[[cascade]]
type = "docs"
+++

As with many other business management systems, the Muse Systems Business Management System (MuseBMS) is a large, enterprise class system trying to solve many different problems in business computing.  In an ideal world each distinct business problem would be solved by a dedicated application built for purpose.  Taking this siloed approach, however, would result in pushing the complexity out of individual applications into a still more complex set of integration layers which would have to harmonize data, timing, and enforce controls across all applications used by the business.  And this is the crux of why large, complex, and often times unwieldy enterprise business systems are created: it is less complex and unwieldy to solve these problems together than separately.  Ultimately all of the individual and seemingly independent functions of a business must work in harmony and coordination with each other for the business as a whole to be successful and maximally efficient.  The software a business uses should facilitate the cross business unit flow of information and allow for coordination of business activities that wouldn't otherwise be possible without the software.

None of this is to say that we shouldn't attempt to bring as much order as possible to the problem of enterprise software development; if we are to create a workable and maintainable business management system our efforts in this regard are essential.  Herein we'll document the technical aspects of the MuseBMS, but also put forth a larger set of principles by which we'll organize our application in an attempt to make the entire system as manageable as possible.

## Foundational Technologies

The application is built using a few core, widely available open source technologies which include:

  * <a href="https://postgresql.org" target="_blank">__PostgreSQL__</a>

    MuseBMS principally stores application data using the PostgreSQL Object Relational Database Management System (ORDBMS).  There are incidental uses of other kinds of data management mechanisms, but for the most part these are bundled modules in the application programming environment (Elixir/BEAM) and are used to facilitate systems operations more than core application features.

  * <a href="https://elixir-lang.org" target="_blank">__Elixir__</a>

    The application server is written using the Elixir programming language.  Elixir is a language which runs on the Erlang BEAM Virtual Machine, "<a href="https://elixir-lang.org" target="_blank">known for creating low-latency, distributed, and fault-tolerant systems.</a>"

  * <a href="https://phoenixframework.org" target="_blank"> __Phoenix Framework__</a>

    The Phoenix Framework is used to create complex, interactive web based user interfaces and APIs using Elixir.

  * <a href="https://gohugo.io" target="_blank"> __Hugo__</a> & The <a href="https://www.docsy.dev" target="_blank"> __Docsy__</a> Theme for Hugo

    This documentation is created using the Hugo static web site generator and the Docsy theme for Hugo.  Our Elixir API documentation is create using Elixir's <a href="https://hexdocs.pm/ex_doc" target="_blank"> __ExDoc__</a> library.

Naturally there are many other libraries and technologies involved in supporting more specific or niche roles, but the three listed above are foundational technologies used in the MuseBMS.