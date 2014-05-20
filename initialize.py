# coding=utf-8
"""
vim-pyenv initialization script
"""
__author__ = 'Alisue <lambdalisue@hashnote.net>'
import vim
import os
import sys

# update the sys path to include the pyenv_vim script
sys.path.insert(0, vim.eval("expand(s:repository_root)"))

# import pyenv_vim so the vimscript can use it
import pyenv_vim
