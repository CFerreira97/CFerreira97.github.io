import logging
from pathlib import Path

LOGS_DIR = Path(__file__).resolve().parents[4] / "logs"


def build_module_logger(
    root_logger: logging.Logger, module_name: str
) -> logging.Logger:
    """Logger for `module_name`, writing to its own file under logs/."""
    logger = root_logger.getChild(module_name)
    if logger.handlers:
        return logger

    LOGS_DIR.mkdir(exist_ok=True)
    handler = logging.FileHandler(LOGS_DIR / f"{module_name}.log")
    handler.setFormatter(
        logging.Formatter("%(asctime)s %(levelname)s %(name)s: %(message)s")
    )
    logger.addHandler(handler)
    logger.propagate = False
    return logger
