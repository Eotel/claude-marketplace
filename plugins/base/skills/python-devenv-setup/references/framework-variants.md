# Framework Configuration Variants

Framework-specific settings for Django, FastAPI, and Flask in pyproject.toml.

## Django

### Dependencies

```toml
[project]
dependencies = [
  "django>=5.0",
  "djangorestframework>=3.15",
  "django-filter>=24.0",
]

[dependency-groups]
dev = [
  "pytest>=8.0",
  "pytest-django>=4.8",
  "pytest-cov>=4.0",
  "ruff>=0.11",
  "ty>=0.0.1",
]
```

### Ruff isort Configuration

```toml
[tool.ruff.lint.isort]
section-order = [
  "future",
  "standard-library",
  "django",
  "third-party",
  "first-party",
  "local-folder",
]

[tool.ruff.lint.isort.sections]
django = ["django", "rest_framework", "django_filters"]
```

### ty Configuration

```toml
[tool.ty.environment]
python-version = "3.12"

[tool.ty.src]
include = ["src", "tests"]

[tool.ty.rules]
# Django uses dynamic model attributes; relax unresolved references
possibly-unresolved-reference = "warn"
possibly-missing-attribute = "warn"
```

### Pytest Configuration

```toml
[tool.pytest.ini_options]
DJANGO_SETTINGS_MODULE = "config.settings"
testpaths = ["tests"]
python_files = ["test_*.py"]
```

## FastAPI

### Dependencies

```toml
[project]
dependencies = [
  "fastapi>=0.110",
  "uvicorn[standard]>=0.29",
  "pydantic>=2.0",
  "pydantic-settings>=2.0",
]

[dependency-groups]
dev = [
  "pytest>=8.0",
  "pytest-asyncio>=0.23",
  "pytest-cov>=4.0",
  "httpx>=0.27",
  "ruff>=0.11",
  "ty>=0.0.1",
]
```

### Ruff isort Configuration

```toml
[tool.ruff.lint.isort]
section-order = [
  "future",
  "standard-library",
  "fastapi",
  "third-party",
  "first-party",
  "local-folder",
]

[tool.ruff.lint.isort.sections]
fastapi = ["fastapi", "pydantic", "starlette"]
```

### ty Configuration

```toml
[tool.ty.environment]
python-version = "3.12"

[tool.ty.src]
include = ["src", "tests"]

[tool.ty.rules]
possibly-unresolved-reference = "warn"
```

### Pytest Configuration

```toml
[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py"]
asyncio_mode = "auto"
```

## Flask

### Dependencies

```toml
[project]
dependencies = [
  "flask>=3.0",
  "flask-sqlalchemy>=3.1",
  "flask-migrate>=4.0",
]

[dependency-groups]
dev = [
  "pytest>=8.0",
  "pytest-flask>=1.3",
  "pytest-cov>=4.0",
  "ruff>=0.11",
  "ty>=0.0.1",
]
```

### Ruff isort Configuration

```toml
[tool.ruff.lint.isort]
section-order = [
  "future",
  "standard-library",
  "flask",
  "third-party",
  "first-party",
  "local-folder",
]

[tool.ruff.lint.isort.sections]
flask = ["flask", "flask_sqlalchemy", "flask_migrate"]
```

### ty Configuration

```toml
[tool.ty.environment]
python-version = "3.12"

[tool.ty.src]
include = ["src", "tests"]

[tool.ty.rules]
possibly-unresolved-reference = "warn"
```

## No Framework (Library/CLI)

### Dependencies

```toml
[project]
dependencies = []

[dependency-groups]
dev = [
  "pytest>=8.0",
  "pytest-cov>=4.0",
  "ruff>=0.11",
  "ty>=0.0.1",
]
```

### Ruff isort Configuration

Standard configuration without custom sections:

```toml
[tool.ruff.lint.isort]
section-order = [
  "future",
  "standard-library",
  "third-party",
  "first-party",
  "local-folder",
]
```

### ty Configuration

```toml
[tool.ty.environment]
python-version = "3.12"

[tool.ty.src]
include = ["src", "tests"]
```

## Type Checking Strictness Levels

### Standard (Default)

Uses ty's default rule severities. No additional configuration needed beyond the base `[tool.ty]` section.

### Strict (`--strict-types`)

Elevate key rules to `"error"` severity for stricter type enforcement:

```toml
[tool.ty.rules]
possibly-unresolved-reference = "error"
possibly-missing-attribute = "error"
invalid-assignment = "error"
invalid-return-type = "error"
invalid-argument-type = "error"
call-non-callable = "error"
invalid-type-arguments = "error"
invalid-method-override = "error"
deprecated = "warn"
redundant-cast = "warn"
```
