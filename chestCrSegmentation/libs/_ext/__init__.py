
#from torch.utils.ffi import _wrap_function
import sys
import os
#sys.path.append("../")
sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)),".."))
from torch_ffi import _wrap_function
from .__ext import lib as _lib, ffi as _ffi

__all__ = []
def _import_symbols(locals):
    for symbol in dir(_lib):
        fn = getattr(_lib, symbol)
        if callable(fn):
            locals[symbol] = _wrap_function(fn, _ffi)
        else:
            locals[symbol] = fn
        __all__.append(symbol)

_import_symbols(locals())
