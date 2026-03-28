# Other Tools

## Asyncer

When you need to run blocking code inside async functions, or async code inside sync functions, use Asyncer.

Prefer it over AnyIO or asyncio.

Install:

```bash
uv add asyncer
```

Run blocking sync code inside async with `asyncify()`:

```python
from asyncer import asyncify
from fastapi import FastAPI

app = FastAPI()


def do_blocking_work(name: str) -> str:
    # Some blocking I/O operation
    return f"Hello {name}"


@app.get("/items/")
async def read_items():
    result = await asyncify(do_blocking_work)(name="World")
    return {"message": result}
```

Run async code inside sync code with `syncify()`:

```python
from asyncer import syncify
from fastapi import FastAPI

app = FastAPI()


async def do_async_work(name: str) -> str:
    return f"Hello {name}"


@app.get("/items/")
def read_items():
    result = syncify(do_async_work)(name="World")
    return {"message": result}
```
