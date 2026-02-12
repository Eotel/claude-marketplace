---
name: node2nix
description: >-
  Packaging Node.js apps (npm/pnpm/bun) as Nix derivations. Use when creating
  buildNpmPackage expressions, fetchPnpmDeps-based derivations, or integrating
  JavaScript/TypeScript CLI tools into nix-darwin or NixOS configurations.
user-invocable: false
---

# Packaging Node.js Apps as Nix Derivations

## Decision Tree

Identify the lockfile in the project root, then choose the approach:

| Lockfile | Package Manager | Nix Approach |
|----------|----------------|--------------|
| `package-lock.json` | npm | `buildNpmPackage` (preferred) or `importNpmLock` |
| `pnpm-lock.yaml` | pnpm | `stdenv.mkDerivation` + `fetchPnpmDeps` + `pnpmConfigHook` |
| `bun.lockb` / `bun.lock` | bun | No native Nix builder — use npx wrapper or convert to npm |

If the project has **no lockfile**, generate one first (`npm install`, `pnpm install`, or `bun install`) and commit it.

## Approach 1: buildNpmPackage (npm)

For projects with `package-lock.json`. This is the most mature path.

```nix
{ lib, buildNpmPackage, fetchFromGitHub }:

buildNpmPackage rec {
  pname = "my-tool";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "owner";
    repo = "repo";
    rev = "v${version}";
    hash = ""; # Build once to get hash
  };

  npmDepsHash = ""; # Build once to get hash

  # If the project has a build step (TypeScript, bundler, etc.)
  # it runs automatically via `npm run build` in the build phase.
  # Set this to skip the build phase if there is no build script:
  # dontNpmBuild = true;

  meta = {
    description = "Description";
    homepage = "https://github.com/owner/repo";
    license = lib.licenses.mit;
    mainProgram = "my-tool";
  };
}
```

### Key attributes

- **`npmDepsHash`** — Hash of the npm dependency tarball. Leave empty on first build, then copy from the error.
- **`dontNpmBuild`** — Set to `true` if `package.json` has no `build` script.
- **`npmFlags`** — Extra flags passed to `npm ci` (e.g. `[ "--legacy-peer-deps" ]`).
- **`makeCacheWritable`** — Set `true` if postinstall scripts write to the cache.
- **`NODE_OPTIONS`** — Set `"--openssl-legacy-provider"` for older webpack projects.

### importNpmLock alternative

For projects that need a more granular lock-based approach:

```nix
{ lib, stdenv, importNpmLock, fetchFromGitHub, nodejs }:

stdenv.mkDerivation {
  pname = "my-tool";
  version = "1.0.0";

  src = fetchFromGitHub { /* ... */ };

  npmDeps = importNpmLock.buildNodeModules {
    npmRoot = ./.;
    nodejs = nodejs;
  };

  # ...
}
```

Use `importNpmLock` when `buildNpmPackage` hash computation is unreliable (e.g. packages with platform-specific optional deps).

## Approach 2: stdenv + fetchPnpmDeps (pnpm)

For projects with `pnpm-lock.yaml`. There is **no `buildPnpmPackage`** helper in nixpkgs yet, so assemble manually.

```nix
{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  nodejs,
  pnpm_10, # Pin to the major version matching the project
  pnpmConfigHook,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "my-tool";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "owner";
    repo = "repo";
    rev = "v${finalAttrs.version}";
    hash = ""; # Build once to get hash
  };

  nativeBuildInputs = [
    nodejs
    pnpm_10
    pnpmConfigHook
    makeWrapper
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_10;
    hash = ""; # Build once to get hash
  };

  buildPhase = ''
    runHook preBuild
    pnpm build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/${finalAttrs.pname} $out/bin
    cp -r dist node_modules package.json $out/lib/${finalAttrs.pname}/
    makeWrapper ${nodejs}/bin/node $out/bin/${finalAttrs.pname} \
      --add-flags "$out/lib/${finalAttrs.pname}/dist/index.js"
    runHook postInstall
  '';

  meta = {
    description = "Description";
    homepage = "https://github.com/owner/repo";
    license = lib.licenses.mit;
    mainProgram = "my-tool";
  };
})
```

### pnpm version matching

The pnpm version **must** match the lockfile format. Mismatches cause silent corruption.

| Lockfile `lockfileVersion` | Nix attribute |
|---------------------------|---------------|
| `'6.0'` or `'6.1'` | `pnpm_8` |
| `'9.0'` | `pnpm_9` or `pnpm_10` |

Check the first line of `pnpm-lock.yaml` for the version.

### TypeScript projects

The `buildPhase` invokes whatever `pnpm build` (or `pnpm run build`) triggers in `package.json`. This typically runs `tsc`, `tsup`, `esbuild`, or a bundler. Do not call `tsc` directly — use the project's build script.

### Monorepo projects

For pnpm workspaces, you may need to build sub-packages first:

```nix
buildPhase = ''
  runHook preBuild
  pnpm --filter ui build   # Build dependency workspace first
  pnpm build               # Then build the main package
  runHook postBuild
'';

installPhase = ''
  runHook preInstall
  mkdir -p $out/lib/${finalAttrs.pname} $out/bin
  cp -r dist node_modules package.json $out/lib/${finalAttrs.pname}/
  # Copy workspace packages if needed at runtime
  if [ -d packages ]; then
    cp -r packages $out/lib/${finalAttrs.pname}/
  fi
  makeWrapper ${nodejs}/bin/node $out/bin/${finalAttrs.pname} \
    --add-flags "$out/lib/${finalAttrs.pname}/dist/entry.js"
  runHook postInstall
'';
```

## Approach 3: Bun

There is **no native Nix builder for bun** lockfiles. Options:

1. **Convert to npm** — Run `npm install` to generate `package-lock.json`, then use `buildNpmPackage`.
2. **npx wrapper alias** — For CLI tools you don't need to build from source, add a shell alias instead of a Nix derivation (see "When NOT to package" below).
3. **Raw stdenv** — Fetch deps manually with `fetchurl`/`fetchzip` and wire them up. Only viable for projects with few deps.

## Hash Generation Workflow

Hashes for `src`, `npmDepsHash`, and `pnpmDeps` are unknown until the first build.

1. Set hash fields to empty string: `hash = "";`
2. Attempt a build: `nix build .#my-tool` (or `darwin-rebuild switch`)
3. The build fails with: `got: sha256-XXXX...`
4. Copy the `sha256-...` value into the corresponding hash field
5. Repeat for each hash (usually `src` hash first, then deps hash)

This is the standard Nix workflow. There is no shortcut.

## Integration with nix-darwin / home-manager

### File structure

Place the derivation in a dedicated file:

```
home/
  packages/
    my-tool.nix    # The derivation
  pkgs.nix         # Package list
```

### Wire it into home.packages

In `pkgs.nix` (or equivalent):

```nix
home.packages = [
  # ... other packages ...
  (pkgs.callPackage ./packages/my-tool.nix { })
];
```

`callPackage` automatically passes nixpkgs attributes matching the function arguments.

## Native Modules (node-gyp)

If the project depends on native addons (e.g. `better-sqlite3`, `sharp`, `bcrypt`):

```nix
nativeBuildInputs = [
  nodejs
  pnpm_10
  pnpmConfigHook
  makeWrapper
  python3      # Required by node-gyp
  pkg-config   # For finding native libraries
];

buildInputs = [
  # Add native dependencies here, e.g.:
  # vips        # for sharp
  # sqlite      # for better-sqlite3
];
```

## Common Pitfalls

| Problem | Cause | Fix |
|---------|-------|-----|
| `hash mismatch` after update | Upstream changed deps | Rebuild with `hash = ""` to get new hash |
| `EACCES` in build | Sandbox blocks network | Ensure all deps are fetched via `fetchPnpmDeps`/`npmDepsHash` |
| `postinstall` script fails | Scripts try to download binaries | Set `npmFlags = [ "--ignore-scripts" ]` or patch |
| `pnpm: command not found` | Wrong pnpm version in `nativeBuildInputs` | Match `pnpm_N` to lockfile version |
| `tsc: not found` in build | TypeScript is a devDep, not in PATH | Use `pnpm build` (or `npm run build`) which resolves local bins |
| Missing files at runtime | `installPhase` didn't copy enough | Check what the entrypoint imports and copy those dirs |

## When NOT to Package

Not every Node.js tool needs a Nix derivation. Prefer lighter alternatives when:

- **npx/bunx alias** — For tools used interactively, an alias is simpler:
  ```nix
  # In shell aliases
  alias my-tool="npx my-tool@latest"
  ```
- **devbox/devenv** — For project-local dev tools, use a dev shell instead.
- **Flake input** — If the upstream project already provides a flake, use it directly as a flake input.

Only build a Nix derivation when you need reproducible, globally-available CLI tools or system services.

## Don't

- **Don't use `node2nix`** — The tool is unmaintained and incompatible with modern Node.js/lockfile versions.
- **Don't use `pnpm2nix`** — Unmaintained, broken with lockfile versions > 5.0.
- **Don't use `yarn2nix`** — Only works with Yarn v1.
- **Don't hardcode absolute paths** — Use `makeWrapper` to set up `NODE_PATH` and entry points.
- **Don't run `npm install` or `pnpm install` in `buildPhase`** — Deps must come from the fixed-output derivation (`npmDepsHash`/`fetchPnpmDeps`). Network access is blocked in the sandbox.
- **Don't pin `nodejs` to a specific major version** unless the project requires it — use the default `nodejs` attribute.
- **Don't mix pnpm versions** — If the project uses pnpm 10, use `pnpm_10` everywhere (both `nativeBuildInputs` and `fetchPnpmDeps`).
