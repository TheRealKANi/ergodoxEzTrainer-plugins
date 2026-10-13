# ergodoxEzTrainer plugin repository (template)

A template for a repository of signed plugins for
[ergodoxEzTrainer](https://github.com/TheRealKANi). Copy it, put your own key in, and replace
the example plugin with yours.

## Use it (for your users)

In ergodoxEzTrainer: **Settings → Plugins → Repos → Add repo** with this repository's URL. The
program fetches it with `git`, shows the fingerprint of its signing key, and installs only
plugins signed with that key. Publish the fingerprint here so users can compare:

| Key | Fingerprint |
|---|---|
| your name | `XXXX XXXX XXXX XXXX` |

## Plugins

| Plugin | Kind | What it does |
|---|---|---|
| Keystroke counter (`hello-overlay`) | overlay | Example: counts the keys you were asked to press |

## Layout

```
repo.toml               name, description, public key
minisign.pub            the public key
index.toml(.minisig)    the plugin list, written by release.sh
plugins/*.zip(.minisig) released plugins; never changed once released
src/<id>/               plugin sources
release.sh              pack, index and sign
```

## Set up (once)

```sh
minisign -G -p minisign.pub -s ~/.minisign/ergodoxEzTrainer.key
```

- Keep the secret key offline and out of every repository (`.gitignore` blocks `*.key`).
- Put the second line of `minisign.pub` into `repo.toml` as `public_key`.
- Put the key id (the end of the first line of `minisign.pub`, in groups of four) into the
  fingerprint table above.
- Change `name` and `description` in `repo.toml`, and the plugin table.

## Release

Change a plugin under `src/`, raise its `version` in `plugin.toml`, then

```sh
./release.sh           # check, pack new versions, write index.toml, sign, verify
```

and commit and push. The repository must hold a signed `index.toml` before anyone adds it.
A released zip is never rebuilt; `release.sh` refuses if a plugin changed without a new
version. `.gitattributes` keeps git from touching the bytes of signed files.

Writing plugins: see `PLUGIN-API.md` in ergodoxEzTrainer.

## If the key is stolen

Revoke it with the key itself, so every ergodoxEzTrainer that reads this repository switches
it off for good:

```sh
echo 'revoke = ["KEYID"]' > revoked.toml
minisign -S -s ~/.minisign/ergodoxEzTrainer.key -m revoked.toml
```

Commit and push `revoked.toml` and `revoked.toml.minisig`, then start over with a new key and
a new repository.

## Licence

The template and the example are GPL-3.0-or-later ([`LICENSE`](LICENSE)). Your own plugins
can use any licence compatible with how you distribute them.
