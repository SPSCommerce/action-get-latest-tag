# Action Get Latest Tag

This is a GitHub Action to get a latest Git tag.

It would be more useful to use this with other GitHub Actions' outputs.

## Inputs

|          NAME          |                                                  DESCRIPTION                                                  |   TYPE   | REQUIRED | DEFAULT  |
|------------------------|---------------------------------------------------------------------------------------------------------------|----------|----------|----------|
| `semver_only`          | Whether gets only a tag in the shape of semver. `v` prefix is accepted for tag names.                         | `bool`   | `false`  | `false`  |
| `initial_version`      | The initial version. Works only when `inputs.with_initial_version` == `true`.                                 | `string` | `false`  | `v0.0.0` |
| `with_initial_version` | Whether returns `inputs.initial_version` as `outputs.tag` if no tag exists. `true` and `false` are available. | `bool`   | `false`  | `true`   |

If `inputs.semver_only` is `true`, the latest tag among tags with semver will be set for `outputs.tag`.

This input is useful for versioning that binds a major version is the latest of that major version (e.g., `v1` == `v1.*`), like GitHub Actions.
In such a case, the actual latest tag is a major version, but the version isn't as we expected when we want to work with semver.

Let's say you did the following versioning.

```console
$ git tag v1.0.0 && git push origin v1.0.0
$ # some commits...
$ git tag v1.1.0 && git push origin v1.1.0
$ git tag v1 && git push origin v1 # bind v1 to v1.1.0.
```

In such a case, `outputs.tag` varies like this:

- `inputs.semver_only`=`false` -> `outputs.tag`=`v1`
- `inputs.semver_only`=`true` -> `outputs.tag`=`v1.1.0`

## Outputs

| NAME  |                                            DESCRIPTION                                             |   TYPE   |
|-------|----------------------------------------------------------------------------------------------------|----------|
| `tag` | The latest tag. If no tag exists and `inputs.with_initial_version` == `false`, this value is `''`. | `string` |

## Example

```yaml
name: Push a new tag with Pull Request

on:
  pull_request:
    types: [closed]

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - uses: actions-ecosystem/action-release-label@v1
        id: release-label
        if: ${{ github.event.pull_request.merged == true }}

      - uses: actions-ecosystem/action-get-latest-tag@v1
        id: get-latest-tag
        if: ${{ steps.release-label.outputs.level != null }}

      - uses: actions-ecosystem/action-bump-semver@v1
        id: bump-semver
        if: ${{ steps.release-label.outputs.level != null }}
        with:
          current_version: ${{ steps.get-latest-tag.outputs.tag }}
          level: ${{ steps.release-label.outputs.level }}

      - uses: actions-ecosystem/action-push-tag@v1
        if: ${{ steps.release-label.outputs.level != null }}
        with:
          tag: ${{ steps.bump-semver.outputs.new_version }}
          message: '${{ steps.bump-semver.outputs.new_version }}: PR #${{ github.event.pull_request.number }} ${{ github.event.pull_request.title }}'
```

For a further practical example, see [.github/workflows/release.yml](.github/workflows/release.yml).

## License

Copyright 2020 The Actions Ecosystem Authors.

Action Get Latest Tag is released under the [Apache License 2.0](./LICENSE).