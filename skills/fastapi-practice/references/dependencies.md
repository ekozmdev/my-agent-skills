# Dependency Injection

Use dependencies when:

* They cannot be expressed only with Pydantic validation and need additional logic
* The logic depends on external resources or could block in some way
* Other dependencies need their results as sub-dependencies
* The logic should be shared across multiple endpoints for things like early errors or authentication
* They need cleanup, such as DB sessions or file handles, using dependencies with `yield`
* They need input from the request, such as headers or query parameters

## Dependencies with `yield` and `scope`

When using dependencies with `yield`, you can use `scope` to define when the cleanup code runs.

Use the default scope `"request"` to run the cleanup code after the response is sent back.

```python
from typing import Annotated

from fastapi import Depends, FastAPI

app = FastAPI()


def get_db():
    db = DBSession()
    try:
        yield db
    finally:
        db.close()


DBDep = Annotated[DBSession, Depends(get_db)]


@app.get("/items/")
async def read_items(db: DBDep):
    return db.query(Item).all()
```

Use `scope="function"` when the cleanup code should run after the response data is generated but before the response is sent back to the client.

```python
from typing import Annotated

from fastapi import Depends, FastAPI

app = FastAPI()


def get_username():
    try:
        yield "Rick"
    finally:
        print("Cleanup up before response is sent")

UserNameDep = Annotated[str, Depends(get_username, scope="function")]

@app.get("/users/me")
def get_user_me(username: UserNameDep):
    return username
```

## Class dependencies

Avoid using classes directly as dependencies when possible.

If you need a class, prefer creating a regular function dependency that returns a class instance.

Do this:

```python
from dataclasses import dataclass
from typing import Annotated

from fastapi import Depends, FastAPI

app = FastAPI()


@dataclass
class DatabasePaginator:
    offset: int = 0
    limit: int = 100
    q: str | None = None

    def get_page(self) -> dict:
        # Simulate a page of data
        return {
            "offset": self.offset,
            "limit": self.limit,
            "q": self.q,
            "items": [],
        }


def get_db_paginator(
    offset: int = 0, limit: int = 100, q: str | None = None
) -> DatabasePaginator:
    return DatabasePaginator(offset=offset, limit=limit, q=q)


PaginatorDep = Annotated[DatabasePaginator, Depends(get_db_paginator)]


@app.get("/items/")
async def read_items(paginator: PaginatorDep):
    return paginator.get_page()
```

instead of:

```python
# DO NOT DO THIS
from typing import Annotated

from fastapi import Depends, FastAPI

app = FastAPI()


class DatabasePaginator:
    def __init__(self, offset: int = 0, limit: int = 100, q: str | None = None):
        self.offset = offset
        self.limit = limit
        self.q = q

    def get_page(self) -> dict:
        # Simulate a page of data
        return {
            "offset": self.offset,
            "limit": self.limit,
            "q": self.q,
            "items": [],
        }


@app.get("/items/")
async def read_items(paginator: Annotated[DatabasePaginator, Depends()]):
    return paginator.get_page()
```

## Service-layer boundaries

Routers and dependency definitions can depend on FastAPI, but the service layer should not.

Do not use `HTTPException`, `Request`, `Response`, `status`, `BackgroundTasks`, or `Depends` directly in the service layer.

Service-layer code should accept regular arguments and return regular values or application-specific exceptions.

Do this:

```python
class UserNotFoundError(Exception):
    pass


class UserService:
    def __init__(self, repo: UserRepository) -> None:
        self.repo = repo

    def get_user(self, user_id: int) -> User:
        user = self.repo.find_by_id(user_id)
        if user is None:
            raise UserNotFoundError(user_id)
        return user
```

```python
from fastapi import APIRouter, HTTPException

router = APIRouter()


@router.get("/users/{user_id}", response_model=UserResponse)
def get_user(user_id: int, service: UserServiceDep) -> UserResponse:
    try:
        user = service.get_user(user_id)
    except UserNotFoundError as exc:
        raise HTTPException(status_code=404, detail="User not found") from exc
    return UserResponse.model_validate(user)
```

instead of:

```python
# DO NOT DO THIS
from fastapi import HTTPException


class UserService:
    def __init__(self, repo: UserRepository) -> None:
        self.repo = repo

    def get_user(self, user_id: int) -> User:
        user = self.repo.find_by_id(user_id)
        if user is None:
            raise HTTPException(status_code=404, detail="User not found")
        return user
```
