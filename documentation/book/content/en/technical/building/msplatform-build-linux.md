+++
title = "Msplatform Build Process / Linux"
linkTitle = "msplatform-build-linux"
description = "Instructions for building the Msplatform Elixir application as a release.  This process targets Linux x86_64 systems."

draft = false

weight = 10
+++

When building <a href="/technical/system-components-list/#msplatform">`Msplatform`</a> we assume that we are including ERTS as part of the release.

We largely follow the standard Phoenix <a href="https://hexdocs.pm/phoenix/releases.html" target="_blank">"Deploying with Releases"</a> documentation to build a release, modified somewhat to support both the umbrella project structure and our own needs.  this process looks like:

```fish
mkdir msplatform_linux_release
cd msplatform_linux_release
git clone https://github.com/MuseSystems/musebms.git --branch versions
cd musebms/app_server/platform/msplatform
mix deps.get --only prod
MIX_ENV=prod mix compile
cd apps/msapp_mcp_web
MIX_ENV=prod mix assets.deploy
MIX_ENV=prod mix phx.gen.release
cd ../../
MIX_ENV=prod mix release
cd _build/prod/rel
tar -cvjSf ../../../../../../../msplatform_release.tar.bz2 msplatform
cd ../../../../../../../
```