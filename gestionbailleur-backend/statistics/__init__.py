"""
Application Django statistics
"""
import sys
import importlib.util

_stdlib_stats_module = None
for _p in sys.path:
    if 'python' in _p.lower() and ('lib' in _p.lower()) and 'site-packages' not in _p.lower():
        try:
            _spec = importlib.util.spec_from_file_location("_stdlib_statistics", _p + "\\statistics.py")
            if _spec and _spec.loader:
                _mod = importlib.util.module_from_spec(_spec)
                _spec.loader.exec_module(_mod)
                _stdlib_stats_module = _mod
                break
        except Exception:
            pass

def __getattr__(name):
    if _stdlib_stats_module and hasattr(_stdlib_stats_module, name):
        return getattr(_stdlib_stats_module, name)
    raise AttributeError(f"module '{__name__}' has no attribute '{name}'")

