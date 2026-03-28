# Settings

Use `pydantic-settings` to centralize environment variable loading.

Keep required-value checks, default values, type conversion, and environment-variable mapping inside `Settings`.

Do not call `os.getenv()` directly in usage sites.

Do not repeat presence checks for the same settings values at usage sites.

Resolve required values when `Settings` is initialized, and allow `None` only for values that are actually optional.

## Create `get_settings()`

Centralize `Settings` creation in a cached `get_settings()` with `@lru_cache`.

```python
from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    app_name: str = "my-app"
    api_base_url: str
    sentry_dsn: str | None = None
    timeout_seconds: float = 5.0

    model_config = SettingsConfigDict(
        env_file=".env",
        env_prefix="APP_",
        extra="ignore",
    )


@lru_cache
def get_settings() -> Settings:
    return Settings()
```

## Usage sites

At usage sites, read settings through `get_settings()`.

Because required values are guaranteed in `Settings`, do not add extra presence checks in the usage site.

```python
def build_client() -> Client:
    settings = get_settings()
    return Client(
        base_url=settings.api_base_url,
        timeout=settings.timeout_seconds,
    )
```

Do not do this:

```python
# DO NOT DO THIS
def build_client() -> Client:
    settings = get_settings()
    if not settings.api_base_url:
        raise RuntimeError("APP_API_BASE_URL is required")
    return Client(base_url=settings.api_base_url)
```

Do not assume `Settings` will be injected as a FastAPI dependency. When settings are needed, call `get_settings()` directly.
