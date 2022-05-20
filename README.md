# ppkg-core-macos-x86_64

essential tools that are used by [ppkg](https://github.com/leleliu008/ppkg) shell script.

these tools are no any dependencies except `libSystem.B.dylib`.

these tools are relocatable which means that you can installed them anywhere.

## Environment Variables
following environment variables should be set for git:
```bash
export GIT_EXEC_PATH="$PPKG_CORE_INSTALL_DIR/libexec/git-core"
export GIT_TEMPLATE_DIR="$PPKG_CORE_INSTALL_DIR/share/git-core/templates"
```

following environment variables should be set for file:
```bash
export MAGIC="$PPKG_CORE_INSTALL_DIR/share/misc/magic.mgc"
```
