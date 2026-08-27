import logging

from cferreira97_github_io.config import settings

from .core import build_module_logger

_root_logger = logging.getLogger("cferreira97_github_io")
_root_logger.setLevel(settings.log_level)


def get_module_logger(module_name: str) -> logging.Logger:
    return build_module_logger(_root_logger, module_name)


__all__ = ["get_module_logger"]
