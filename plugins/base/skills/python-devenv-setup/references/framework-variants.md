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

[project.optional-dependencies]
dev = [
  "pytest>=8.0",
  "pytest-django>=4.8",
  "pytest-cov>=4.0",
  "mypy>=1.10",
  "django-stubs>=5.0",
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

### MyPy Configuration

```toml
[tool.mypy]
python_version = "3.12"
plugins = ["mypy_django_plugin.main"]
strict = false
warn_return_any = true
warn_unused_configs = true
exclude = [
  "migrations/",
  "tests/",
]

[tool.django-stubs]
django_settings_module = "config.settings"

[[tool.mypy.overrides]]
module = "*.migrations.*"
ignore_errors = true
```

### Pytest Configuration

```toml
[tool.pytest.ini_options]
DJANGO_SETTINGS_MODULE = "config.settings"
testpaths = ["tests"]
python_files = ["test_*.py"]
```

### pyrightconfig.json for Django

```json
{
  "include": ["src", "tests", "config"],
  "exclude": [
    "**/node_modules",
    "**/__pycache__",
    "**/migrations",
    ".venv",
    "venv"
  ],
  "pythonVersion": "3.12",
  "pythonPlatform": "All",
  "venvPath": ".",
  "venv": ".venv",
  "typeCheckingMode": "standard",
  "reportUnusedImport": "warning",
  "reportUnusedVariable": "warning",
  "reportUnknownMemberType": false,
  "reportUnknownArgumentType": false,
  "reportUnknownVariableType": false,
  "reportAny": false
}
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

[project.optional-dependencies]
dev = [
  "pytest>=8.0",
  "pytest-asyncio>=0.23",
  "pytest-cov>=4.0",
  "httpx>=0.27",
  "mypy>=1.10",
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

### MyPy Configuration

```toml
[tool.mypy]
python_version = "3.12"
plugins = ["pydantic.mypy"]
strict = false
warn_return_any = true
warn_unused_configs = true
exclude = [
  "tests/",
]

[tool.pydantic-mypy]
init_forbid_extra = true
init_typed = true
warn_required_dynamic_aliases = true
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

[project.optional-dependencies]
dev = [
  "pytest>=8.0",
  "pytest-flask>=1.3",
  "pytest-cov>=4.0",
  "mypy>=1.10",
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

### MyPy Configuration

```toml
[tool.mypy]
python_version = "3.12"
strict = false
warn_return_any = true
warn_unused_configs = true
exclude = [
  "migrations/",
  "tests/",
]
```

## No Framework (Library/CLI)

### Dependencies

```toml
[project]
dependencies = []

[project.optional-dependencies]
dev = [
  "pytest>=8.0",
  "pytest-cov>=4.0",
  "mypy>=1.10",
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

### MyPy Configuration

```toml
[tool.mypy]
python_version = "3.12"
strict = false
warn_return_any = true
warn_unused_configs = true
exclude = [
  "tests/",
]
```

## Type Checking Strictness Levels

### Standard (Default)

```json
{
  "typeCheckingMode": "standard",
  "reportUnknownMemberType": false,
  "reportUnknownArgumentType": false,
  "reportUnknownVariableType": false,
  "reportAny": false
}
```

### Strict (--strict-types)

```json
{
  "typeCheckingMode": "strict",
  "reportUnknownMemberType": "warning",
  "reportUnknownArgumentType": "warning",
  "reportUnknownVariableType": "warning",
  "reportAny": "warning"
}
```

And in pyproject.toml:

```toml
[tool.mypy]
strict = true
```
