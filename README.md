# ergodoxEzTrainer plugins

Signed plugins for [ergodoxEzTrainer](https://github.com/TheRealKANi/ergodoxEzTrainer), the trainer for new
keyboard layouts on the ZSA ErgoDox EZ.

## Use it

In ergodoxEzTrainer: **Settings → Plugins → Repos → Add repo** with

```
https://github.com/TheRealKANi/ergodoxEzTrainer-plugins
```

The program fetches the repository with `git` and shows the fingerprint of its signing key.
Trust it only if it matches:

| Key | Fingerprint |
|---|---|
| TheRealKANi | `56EF C366 9786 41CC` |

The program then installs only plugins signed with that key, and asks again with a warning if
the repository ever presents another key. The plugins are under **Browse**.

## Plugins

| Plugin | Kind | What it does |
|---|---|---|
| Keystroke counter (`keystroke-counter`) | overlay | Counts the keys you were asked to press in this session; a small first plugin to try the repository with |

The trainer's own plugins (keyboard, courses, drill, warm-up, memory quiz, hands, Danish …)
are built into the program and are not here.

## Your own plugin repository

Start from the template this repository began as:

```sh
git clone --branch template https://github.com/TheRealKANi/ergodoxEzTrainer-plugins my-plugins
```

Its README explains the key, `repo.toml` and `release.sh`. Writing plugins: see
`PLUGIN-API.md` in ergodoxEzTrainer.

## Layout

```
repo.toml               name, description, public key
minisign.pub            the public key
index.toml(.minisig)    the plugin list, written by release.sh
plugins/*.zip(.minisig) released plugins; never changed once released
src/<id>/               plugin sources
release.sh              pack, index and sign
```

## Release (maintainer)

Change a plugin under `src/`, raise its `version` in `plugin.toml`, then

```sh
./release.sh           # check, pack new versions, write index.toml, sign, verify
```

and commit and push. A released zip is never rebuilt; `release.sh` refuses if a plugin
changed without a new version.

## If the key is ever stolen

The key will be revoked with a signed `revoked.toml` in this repository. Every ergodoxEzTrainer
that reads it then switches the key off for good, and a new repository with a new key will be
announced here.

## Licence

GPL-3.0-or-later, see [`LICENSE`](LICENSE), with the additional terms in ergodoxEzTrainer's
`NOTICE.md`.
