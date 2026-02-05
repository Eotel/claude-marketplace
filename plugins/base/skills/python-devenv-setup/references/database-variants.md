# Database Configuration Variants

Configuration details for MySQL and PostgreSQL support in devenv.nix.

## MySQL Support

### Required Packages

Add to `packages` in devenv.nix:

```nix
packages = [
  # ... other packages
  pkgs.libmysqlclient
  pkgs.libmysqlclient.dev
  pkgs.pkg-config
  pkgs.openssl
];
```

### Environment Variables

Add `env` block for mysqlclient compilation:

```nix
env = {
  MYSQLCLIENT_CFLAGS = "-I${pkgs.libmysqlclient.dev}/include/mariadb";
  MYSQLCLIENT_LDFLAGS = "-L${pkgs.libmysqlclient}/lib/mariadb -lmariadb";
};
```

### Python Dependencies

Add to pyproject.toml:

```toml
dependencies = [
  "mysqlclient>=2.2",
]
```

### Troubleshooting

If compilation fails, verify environment variables:

```bash
echo $MYSQLCLIENT_CFLAGS
echo $MYSQLCLIENT_LDFLAGS
```

Common issues:
- Missing `pkg-config`: Ensure it's in packages list
- Wrong include path: Check MariaDB vs MySQL headers location

## PostgreSQL Support

### Required Packages

Add to `packages` in devenv.nix:

```nix
packages = [
  # ... other packages
  pkgs.postgresql
  pkgs.libpq
];
```

### Environment Variables

Add `env` block for library path:

```nix
env = {
  LD_LIBRARY_PATH = lib.makeLibraryPath [ pkgs.libpq ];
};
```

### Python Dependencies

Add to pyproject.toml:

```toml
dependencies = [
  "psycopg[binary]>=3.1",
]
```

Or for psycopg2:

```toml
dependencies = [
  "psycopg2-binary>=2.9",
]
```

### Troubleshooting

If psycopg fails to find libpq:

```bash
echo $LD_LIBRARY_PATH
```

Ensure the path includes the libpq library directory.

## SQLite (Default)

SQLite requires no additional configuration. Python includes sqlite3 in the standard library.

For enhanced features, add:

```toml
dependencies = [
  "aiosqlite>=0.19",  # Async support
]
```

## Complete devenv.nix Example with MySQL

```nix
{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  languages.python = {
    enable = true;
    version = "3.12";
    uv.enable = true;
  };

  packages = [
    pkgs.ruff
    pkgs.nixfmt-rfc-style
    pkgs.treefmt
    # MySQL support
    pkgs.libmysqlclient
    pkgs.libmysqlclient.dev
    pkgs.pkg-config
    pkgs.openssl
  ];

  env = {
    MYSQLCLIENT_CFLAGS = "-I${pkgs.libmysqlclient.dev}/include/mariadb";
    MYSQLCLIENT_LDFLAGS = "-L${pkgs.libmysqlclient}/lib/mariadb -lmariadb";
  };

  git-hooks.hooks = {
    ruff.enable = true;
    ruff-format.enable = true;
    nixfmt-rfc-style.enable = true;
  };

  enterShell = ''
    echo "Python + MySQL environment ready"
  '';
}
```

## Complete devenv.nix Example with PostgreSQL

```nix
{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  languages.python = {
    enable = true;
    version = "3.12";
    uv.enable = true;
  };

  packages = [
    pkgs.ruff
    pkgs.nixfmt-rfc-style
    pkgs.treefmt
    # PostgreSQL support
    pkgs.postgresql
    pkgs.libpq
  ];

  env = {
    LD_LIBRARY_PATH = lib.makeLibraryPath [ pkgs.libpq ];
  };

  git-hooks.hooks = {
    ruff.enable = true;
    ruff-format.enable = true;
    nixfmt-rfc-style.enable = true;
  };

  enterShell = ''
    echo "Python + PostgreSQL environment ready"
  '';
}
```
