# coding=utf-8
import vim
import sys
import subprocess


# None in Python 2 and Python 3 is a bit different.
# The variable which set as `None` in python 2 would be
# detected as an object which is not None in python 3.
# Thus None like object is required for compatibility.
NONE = 0


# The original sys.path
_original_sys_path = NONE


def py_version():
    """
    Return the version of the executing python to the Vim
    The vimscript can get the value from a `return_value` variable.
    """
    py_version = sys.version.split()[0]
    vim.command('let return_value = "{}"'.format(py_version))


def get_external_sys_path(python_exec=None):
    """
    Get the sys.path value of the external python (system python)
    """
    python_exec = python_exec or 'python'
    # execute the external python and get the sys.path value
    args = [python_exec, '-c', 'import sys; print("\\n".join(sys.path))']
    p = subprocess.Popen(args, stdout=subprocess.PIPE)
    stdout, stderr = p.communicate()
    return stdout.splitlines()


def activate(python_exec=None):
    """
    Update the executing python's sys.path with the external python's sys.path
    """
    global _original_sys_path
    # get current external python's sys.path
    external_sys_path = get_external_sys_path(python_exec)
    # convert it into string (it required in python3)
    if sys.version_info >= (3, 0):
        external_sys_path = [x.decode('utf-8') for x in external_sys_path]
    # save original sys.path
    if _original_sys_path == NONE:
        _original_sys_path = sys.path[:]
    # update sys.path with the origianl sys.path and external sys.path
    sys.path[:] = _original_sys_path
    for path in reversed(external_sys_path):
        # if the path is already specified in original sys.path
        # remove and insert to re-order the appearance
        if path in sys.path:
            sys.path.remove(path)
        sys.path.insert(0, path)


def deactivate():
    """
    Restore the executing python's sys.path
    """
    global _original_sys_path
    # restore original sys path if the original is stored
    if _original_sys_path != NONE:
        sys.path[:] = _original_sys_path
    _original_sys_path = NONE
