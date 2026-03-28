---
name: fastapi-practice
description: FastAPI implementation practices. Use when working with FastAPI APIs and the Pydantic models for them. Keep implementation and structure decisions consistent while writing new code or refactoring existing code.
---

# FastAPI Practice

Skill with FastAPI implementation practices and structure conventions. Use it when you want to keep implementation decisions consistent.

## Use `Annotated`

Always prefer the `Annotated` style for parameter and dependency declarations.

It keeps function signatures easier to reuse in other contexts, preserves the types, and makes reuse easier.

### In Parameter Declarations

Use `Annotated` for parameter declarations, including `Path`, `Query`, `Header`, etc.:

```python
from typing import Annotated

from fastapi import FastAPI, Path, Query

app = FastAPI()


@app.get("/items/{item_id}")
async def read_item(
    item_id: Annotated[int, Path(ge=1, description="The item ID")],
    q: Annotated[str | None, Query(max_length=50)] = None,
):
    return {"message": "Hello World"}
```

instead of:

```python
# DO NOT DO THIS
@app.get("/items/{item_id}")
async def read_item(
    item_id: int = Path(ge=1, description="The item ID"),
    q: str | None = Query(default=None, max_length=50),
):
    return {"message": "Hello World"}
```

### For Dependencies

Use `Annotated` for dependencies with `Depends()`.

Unless asked not to, create a type alias for the dependency to make it reusable.

```python
from typing import Annotated

from fastapi import Depends, FastAPI

app = FastAPI()


def get_current_user():
    return {"username": "johndoe"}


CurrentUserDep = Annotated[dict, Depends(get_current_user)]


@app.get("/items/")
async def read_item(current_user: CurrentUserDep):
    return {"message": "Hello World"}
```

instead of:

```python
# DO NOT DO THIS
@app.get("/items/")
async def read_item(current_user: dict = Depends(get_current_user)):
    return {"message": "Hello World"}
```

## Do not use Ellipsis for path operations or Pydantic models

Do not use `...` as the default value for required values. It is not needed and not recommended.

Do this, without Ellipsis (`...`):

```python
from typing import Annotated

from fastapi import FastAPI, Query
from pydantic import BaseModel, Field


class Item(BaseModel):
    name: str
    description: str | None = None
    price: float = Field(gt=0)


app = FastAPI()


@app.post("/items/")
async def create_item(item: Item, project_id: Annotated[int, Query()]): ...
```

instead of:

```python
# DO NOT DO THIS
class Item(BaseModel):
    name: str = ...
    description: str | None = None
    price: float = Field(..., gt=0)


app = FastAPI()


@app.post("/items/")
async def create_item(item: Item, project_id: Annotated[int, Query(...)]): ...
```

## Return type or response model

When possible, include a return type. It is used for response validation, filtering, documentation, and serialization.

```python
from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()


class Item(BaseModel):
    name: str
    description: str | None = None


@app.get("/items/me")
async def get_item() -> Item:
    return Item(name="Plumbus", description="All-purpose home device")
```

Important: return types and response models help filter data so sensitive fields are not exposed. They are also used by Pydantic for serialization.

The return type does not have to be a Pydantic model. It can also be a list of integers, a dict, etc.

### When to use `response_model` instead

If the actual return type is different from the type you want to use for validation, filtering, or serialization, use `response_model` on the decorator instead.

```python
from typing import Any

from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()


class Item(BaseModel):
    name: str
    description: str | None = None


@app.get("/items/me", response_model=Item)
async def get_item() -> Any:
    return {"name": "Foo", "description": "A very nice Item"}
```

This is especially useful when exposing only public fields and filtering out sensitive information.

```python
from typing import Any

from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()


class InternalItem(BaseModel):
    name: str
    description: str | None = None
    secret_key: str


class Item(BaseModel):
    name: str
    description: str | None = None


@app.get("/items/me", response_model=Item)
async def get_item() -> Any:
    item = InternalItem(
        name="Foo", description="A very nice Item", secret_key="supersecret"
    )
    return item
```

## Performance

Do not use `ORJSONResponse` or `UJSONResponse`, they are deprecated.

Instead, declare a return type or response model. Let Pydantic handle serialization.

## Including routers

When declaring routers, prefer to put router-level configuration like `prefix` and `tags` on the router itself instead of in `include_router()`.

Do this:

```python
from fastapi import APIRouter, FastAPI

app = FastAPI()

router = APIRouter(prefix="/items", tags=["items"])


@router.get("/")
async def list_items():
    return []


# In main.py
app.include_router(router)
```

instead of:

```python
# DO NOT DO THIS
from fastapi import APIRouter, FastAPI

app = FastAPI()

router = APIRouter()


@router.get("/")
async def list_items():
    return []


# In main.py
app.include_router(router, prefix="/items", tags=["items"])
```

There can be exceptions, but follow this convention by default.

Apply shared dependencies at the router level via `dependencies=[Depends(...)]`.

## Dependency injection

See the [dependency injection reference](references/dependencies.md) for detailed patterns, including `yield`, `scope`, and service-layer boundaries.

Use dependencies when the logic cannot be expressed only with Pydantic validation, depends on external resources, needs cleanup with `yield`, or should be shared across multiple endpoints.

Apply shared dependencies at the router level via `dependencies=[Depends(...)]`.

## Settings and environment variables

Use `pydantic-settings` to centralize environment variable loading.

Keep required-value checks, default values, type conversion, and environment-variable mapping inside `Settings` instead of scattering them across call sites.

Create a cached `get_settings()` with `@lru_cache` and centralize settings creation there.

At call sites, read settings through `get_settings()`. Because required values are guaranteed in `Settings`, do not repeat presence checks at the usage site.

See the [settings reference](references/settings.md) for implementation examples.

## Do not bring FastAPI into the service layer

Do not bring FastAPI HTTP classes or HTTP-specific behavior into the service layer.

Keep FastAPI dependencies such as `HTTPException`, `Request`, `Response`, `status`, `BackgroundTasks`, and `Depends` in the endpoint layer or dependency definitions.

Service-layer inputs and outputs should use regular Python values, Pydantic models, and application-specific exceptions. Let routers decide HTTP status codes and response shapes.

This keeps the service layer easier to reuse and easier to test without HTTP.

See the [dependency injection reference](references/dependencies.md) for examples.

## Async vs sync path operations

Use `async` path operations only when you are sure the logic inside is awaitable or does not block.

```python
from fastapi import FastAPI

app = FastAPI()


# Use async def when calling async code
@app.get("/async-items/")
async def read_async_items():
    data = await some_async_library.fetch_items()
    return data


# Use plain def when calling blocking/sync code or when in doubt
@app.get("/items/")
def read_items():
    data = some_blocking_library.fetch_items()
    return data
```

When in doubt, use regular `def` by default. It will run in a threadpool and is less likely to block the event loop.

The same rule applies to dependencies.

Do not run blocking code inside `async` functions. It may work, but it will damage performance.

When you need to mix blocking code and async code, see Asyncer in the [other tools reference](references/other-tools.md).

## Streaming

See the [streaming reference](references/streaming.md) for JSON Lines, Server-Sent Events (`EventSourceResponse`, `ServerSentEvent`), and byte streaming with `StreamingResponse`.

## Other libraries

The [other tools reference](references/other-tools.md) includes notes about:

* Asyncer: use it when mixing async and blocking code. Prefer it over AnyIO or asyncio.

## Do not use Pydantic `RootModel`

Do not use Pydantic `RootModel`. Use regular type annotations, `Annotated`, and Pydantic validation utilities instead.

For example, for a validated list:

```python
from typing import Annotated

from fastapi import Body, FastAPI
from pydantic import Field

app = FastAPI()


@app.post("/items/")
async def create_items(items: Annotated[list[int], Field(min_length=1), Body()]):
    return items
```

instead of:

```python
# DO NOT DO THIS
from typing import Annotated

from fastapi import FastAPI
from pydantic import Field, RootModel

app = FastAPI()


class ItemList(RootModel[Annotated[list[int], Field(min_length=1)]]):
    pass


@app.post("/items/")
async def create_items(items: ItemList):
    return items

```

FastAPI can handle these type annotations directly and create a Pydantic `TypeAdapter` internally, so there is no need to introduce extra RootModel types or special logic.

## Use one HTTP operation per function

Do not mix multiple HTTP operations in one function. One function per HTTP operation keeps responsibilities separated and the code easier to organize.

Do this:

```python
from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()


class Item(BaseModel):
    name: str


@app.get("/items/")
async def list_items():
    return []


@app.post("/items/")
async def create_item(item: Item):
    return item
```

instead of:

```python
# DO NOT DO THIS
from fastapi import FastAPI, Request
from pydantic import BaseModel

app = FastAPI()


class Item(BaseModel):
    name: str


@app.api_route("/items/", methods=["GET", "POST"])
async def handle_items(request: Request):
    if request.method == "GET":
        return []
```
