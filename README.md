# The `srs` Package
<div align="center">Version 0.1.0</div>

Support for Software Requirements Specification in Typst.

> [!IMPORTANT]
> This package is still in beta. Using it now means participating in its development.

<!--
## Template adaptation checklist

- [x] Fill out `README.md`
  - Change the `my-package` package name, including code snippets
  - Check section contents and/or delete sections that don't apply
- [x] Check and/or replace `LICENSE` by something that suits your needs
- [x] Fill out `typst.toml`
  - See also the [typst/packages README](https://github.com/typst/packages/?tab=readme-ov-file#package-format)
- [x] Adapt Repository URLs in `CHANGELOG.md`
  - Consider only committing that file with your first release, or removing the "Initial Release" part in the beginning
- [ ] Adapt or deactivate the release workflow in `.github/workflows/release.yml`
  - to deactivate it, delete that file or remove/comment out lines 2-4 (`on:` and following)
  - to use the workflow
    - [ ] check the values under `env:`, particularly `REGISTRY_REPO`
    - [ ] if you don't have one, [create a fine-grained personal access token](https://github.com/settings/tokens?type=beta) with [only Contents permission](https://stackoverflow.com/a/75116350/371191) for the `REGISTRY_REPO`
    - [ ] on this repo, create a secret `REGISTRY_TOKEN` (at `https://github.com/[user]/[repo]/settings/secrets/actions`) that contains the so created token

    if configured correctly, whenever you create a tag `v...`, your package will be pushed onto a branch on the `REGISTRY_REPO`, from which you can then create a pull request against [typst/packages](https://github.com/typst/packages/)
- [ ] remove/replace the example test case
- [ ] (add your actual code, docs and tests)
- [ ] remove this section from the README
-->

## Getting Started

You can find examples in [`tests/basic/test.typ`](tests/basic/test.typ) and [`tests/jose/test.typ`](tests/jose/test.typ).

You can find the reference documentation in [`docs/manual.pdf`](docs/manual.pdf).

<!--
These instructions will get you a copy of the project up and running on the typst web app. Perhaps a short code example on importing the package and a very simple teaser usage.

```typ
#import "@preview/srs:0.1.0": *

#show: my-show-rule.with()
#my-func()
```

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="./thumbnail-dark.svg">
  <img src="./thumbnail-light.svg">
</picture>
-->

### Installation

To install the package under [your local typst package dir](https://github.com/typst/packages?tab=readme-ov-file#local-packages) you can use the `install` script from the repository.

```bash
just install
```

The installed version can be imported by prefixing the package name with `@local`.

```typ
#import "@local/srs:0.1.0"
```

Alternatively, just copy the contents of the `src/` directory to a `srs` subfolder of your project and:
```typ
#import "srs/lib.typ" as srs
```


<!--
## Usage

A more in-depth description of usage. Any template arguments? A complicated example that showcases most if not all of the functions the package provides? This is also an excellent place to signpost the manual.

```typ
#import "@preview/srs:0.1.0": *

#let my-complicated-example = ...
```
-->


## Additional Documentation and Acknowledgments

* This package is a Typst rewrite of [`srs-latex`](https://github.com/rajayonin/srs-latex), which is based on [J. Lopez-Gomez's `SRS-latex-uc3m`](https://github.com/jalopezg-git/SRS-latex-uc3m)
