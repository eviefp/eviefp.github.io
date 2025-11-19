# Generating/testing locally

```sh
nix develop # enter the shell with the static generator
nix run .#generate # run the static generation
# ^ repeat as needed when changing the static files
http-server docs # start a http server to view changes

# other useful commands
nix run .#clean # cleans 'docs/', do it whenever removing/renaming anything
nix run .#help # see the shake options available
# if you want to use them manually, you'll have to run
cabal run eviefp-blog -- --option-here

nix run .#repl # starts ghci/the repl
```

## Deploying

Pushes to `main` will automatically get mirrored to github to https://github.com/eviefp/blog-mirror and deployed via github pages to https://eevie.ro

> [!WARNING]
> The generated website HTML is currently stored in the repository under `docs`.
> When submitting your PR, make sure to include the generated HTML along with your other changes.
