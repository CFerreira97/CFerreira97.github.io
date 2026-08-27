from cferreira97_github_io.config import settings
from cferreira97_github_io.shared.logging import get_module_logger

logger = get_module_logger(__name__)


def main() -> None:
    logger.info("starting")
    print(f"Hello from cferreira97_github_io! (log level: {settings.log_level})")
