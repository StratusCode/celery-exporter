from dataclasses import dataclass
import typing as t

from configur8 import cfg


# pylint: disable=too-few-public-methods
@dataclass
class CeleryExporter:
    broker_ssl_option: t.Dict[str, str]
    broker_transport_option: t.Dict[str, str]
    broker_url: str
    log_level: str
    port: int = 9808
    retry_interval: int = 0

    def to_click_params(self) -> t.Dict[str, t.Any]:
        # see src/celery_exporter/exporter.py
        return {
            "broker_ssl_option": [
                f"{key}={value}" for key, value in self.broker_ssl_option.items()
            ],
            "broker_transport_option": [
                f"{key}={value}" for key, value in self.broker_transport_option.items()
            ],
            "broker_url": self.broker_url,
            "log_level": self.log_level,
            "port": self.port,
            "retry_interval": self.retry_interval,
        }


class Config:
    celery_exporter: CeleryExporter


def parse(data: t.Any):
    return cfg.parse(Config, data)


def load(path: str | None = None) -> CeleryExporter:
    return cfg.load(Config, path).celery_exporter
