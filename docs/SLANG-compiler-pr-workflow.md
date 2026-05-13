# SLANG-compiler PR 作業メモ

SLANG クロスコンパイラ本体へプルリクエストを出すときの、クリーンな作業ツリー作成とビルド確認のメモです。再インストールテストや、fork を作り直したときの確認用として残します。

## 前提

- GitHub では、同じアカウントに同じ親リポジトリの fork は 1 つだけ作成できます。
- 既存 fork がある場合は、その fork に PR 用ブランチを作成します。
- ローカル確認用に変更した `Makefile` や生成物を混ぜないため、PR 用に新しく clone した作業ツリーで作業すると安全です。

例では既存 fork を `issaUt/SLANG-compiler-mz2500` としています。

## PR 用クリーン作業ツリーを作る

```sh
cd ~/work/SLANG
git clone https://github.com/issaUt/SLANG-compiler-mz2500.git SLANG-compiler-pr-mz2500
cd SLANG-compiler-pr-mz2500
git remote add upstream https://github.com/h-o-soft/SLANG-compiler.git
git fetch upstream
git switch -c mz2500-magic-input upstream/main
```

`git remote add upstream` は親元リポジトリの場所を登録するだけです。実際に最新版を取得するのは `git fetch upstream` です。

`git switch -c mz2500-magic-input upstream/main` で、取得済みの親元最新版を起点にした新しい作業ブランチを作成します。

親元のデフォルトブランチが `master` の場合は、次のようにします。

```sh
git switch -c mz2500-magic-input upstream/master
```

## 必要ファイルだけコピーする

既存のローカル作業ツリーから、PR に含めるファイルだけコピーします。

```sh
cp ../SLANG-compiler-mz2500-local/docs/MZ2500.md docs/MZ2500.md
cp ../SLANG-compiler-mz2500-local/examples/MZ25IOCS.SL examples/MZ25IOCS.SL
cp ../SLANG-compiler-mz2500-local/runtime/env/sosmz2500.env runtime/env/sosmz2500.env
cp ../SLANG-compiler-mz2500-local/runtime/libmz25iocs_input.asm runtime/libmz25iocs_input.asm
cp ../SLANG-compiler-mz2500-local/runtime/libmz2500_magic.asm runtime/libmz2500_magic.asm
```

今回の作業では `images/templates/SOSPROG.D88` は変更対象にしません。

確認します。

```sh
git status --short
git diff --stat
git diff --check
```

PR 対象は次の 5 ファイルを想定します。

- `docs/MZ2500.md`
- `examples/MZ25IOCS.SL`
- `runtime/env/sosmz2500.env`
- `runtime/libmz25iocs_input.asm`
- `runtime/libmz2500_magic.asm`

## ツールと slangbuild を準備する

外部ツールを取得します。

```sh
make setup-tools
```

`setup-tools` は主に `tools/AILZ80ASM` や `mzd88` などを準備します。`bin/slangc` / `bin/slangbuild` は別途作成します。

ソース clone からローカル用の `bin/slangc` / `bin/slangbuild` を作るには、次を実行します。

```sh
make publish-local
```

内部的には .NET の `dotnet publish` を行い、`bin/` に `slangc` と `slangbuild` を配置します。

確認します。

```sh
ls -l bin/slangc bin/slangbuild tools/AILZ80ASM
```

## ビルド確認

開発ツリーでは `Makefile.dist` を指定して確認します。

```sh
make -f Makefile.dist ENV=mz25iocs TARGET=examples/MZ25IOCS asm
make -f Makefile.dist ENV=sosmz2500 TARGET=examples/FMANDEL asm
```

D88 作成まで確認する場合は、次のようにします。

```sh
make -f Makefile.dist ENV=mz25iocs TARGET=examples/MZ25IOCS disk_image
make -f Makefile.dist ENV=sosmz2500 TARGET=examples/FMANDEL disk_image
```

`disk_image` は生成物を作るため、確認後に `git status --short` で PR 対象外のファイルを stage しないように確認します。

## コミットと push

```sh
git add docs/MZ2500.md \
        examples/MZ25IOCS.SL \
        runtime/env/sosmz2500.env \
        runtime/libmz25iocs_input.asm \
        runtime/libmz2500_magic.asm

git diff --cached --stat
git diff --cached --check

git commit -m "Add MZ-2500 MAGIC library and IOCS input support"
git push -u origin mz2500-magic-input
```

その後、GitHub 上で `issaUt/SLANG-compiler-mz2500:mz2500-magic-input` から `h-o-soft/SLANG-compiler` へプルリクエストを作成します。

## PR 本文例

```md
## Summary

- Add MZ-2500 MAGIC runtime library.
- Link MAGIC from `sosmz2500.env`.
- Extend `mz25iocs` input runtime with `GETL`, `GETLIN`, `LINPUT`, and `INPUT`.
- Update `examples/MZ25IOCS.SL` to cover input routines.
- Document MZ-2500 input runtime behavior.

## Notes

`mz25iocs` uses IOCS `SVC_GETL`. `GETL` and `GETLIN` keep the column-0 behavior, while `LINPUT` and `INPUT` skip the prompt portion using the IOCS cursor X position.

## Verification

- `make -f Makefile.dist ENV=mz25iocs TARGET=examples/MZ25IOCS asm`
- `make -f Makefile.dist ENV=sosmz2500 TARGET=examples/FMANDEL asm`
```