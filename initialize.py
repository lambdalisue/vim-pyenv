# coding=utf-8
import vim
import os
import sys

# update the sys path to include the pyenv_vim script
repository_root = vim.eval("expand(s:repository_root)")
if repository_root not in sys.path:
    sys.path.insert(0, repository_root)

# import pyenv_vim so the vimscript can use it
import pyenv_vim
