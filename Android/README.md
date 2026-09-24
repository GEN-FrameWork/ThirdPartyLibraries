# Entorno Android de GEN

Este directorio define y reconstruye el entorno Android que necesita GEN sin
guardar el SDK ni el NDK en Git.

El instalador conserva exactamente las rutas que utiliza el framework:

```text
ThirdPartyLibraries/android-sdk
ThirdPartyLibraries/android-ndk
```

## Versiones fijadas

| Componente | Requisito |
|---|---|
| NDK | `27.3.13750724` (`r27d`), Windows x86_64 |
| Platform Tools | `37.0.0` o posterior |
| Build Tools | `34.0.0` y `35.0.0` |
| SDK Platforms | `android-24`, `android-34` y `android-35` |

Las versiones y los artefactos de arranque están centralizados en
`AndroidPackages.cfg`. Las Command-line Tools sirven únicamente para ejecutar
`sdkmanager`; su versión no forma parte del toolchain de compilación de GEN.

NDK r27d es una versión fijada por compatibilidad con GEN, no la versión más
reciente de Google. Sus datos de versión, tamaño y SHA-1 permanecen publicados
en la [release r27d del proyecto Android NDK](https://github.com/android/ndk/releases/tag/r27d).
La descarga de las Command-line Tools y su SHA-256 proceden de la
[página oficial de Android Studio](https://developer.android.com/studio).

## Requisitos

- Windows x86_64.
- Windows PowerShell 5.1 o posterior.
- Un JDK actual disponible en `PATH` o mediante `JAVA_HOME`.
- Conexión HTTPS a `dl.google.com`.
- Aproximadamente 5 GB libres durante la instalación.

## Instalación

Desde un símbolo del sistema de Windows:

```bat
cd ThirdPartyLibraries
Android\InstallAndroid.bat
```

El instalador:

1. valida los componentes ya presentes;
2. descarga de Google las Command-line Tools si faltan y verifica su SHA-256;
3. acepta las licencias e instala o completa los paquetes del SDK con
   `sdkmanager`;
4. descarga el NDK r27d oficial y verifica el SHA-1 publicado por Google;
5. comprueba `source.properties`, el toolchain de CMake y LLVM;
6. deja el SDK y el NDK en las rutas esperadas por GEN.

Puede ejecutarse tantas veces como sea necesario. Cuando todo es correcto sólo
valida el entorno y termina; no vuelve a descargar ni reinstalar componentes.

Para validar sin cambiar nada:

```bat
Android\InstallAndroid.bat --check
```

## Instalaciones existentes incompatibles

El instalador nunca sobrescribe un `android-ndk` existente que tenga otra
versión o esté incompleto. En ese caso termina con error y pide renombrarlo o
eliminarlo manualmente. Esto evita destruir una instalación local por
accidente.

El SDK se gestiona de forma incremental mediante `sdkmanager`: se conservan sus
otros paquetes y únicamente se instalan o actualizan los requisitos indicados
en `AndroidPackages.cfg`.

No deben guardarse copias de paquetes dentro de `android-sdk`, por ejemplo
`android-sdk\platform-tools.backup`. `sdkmanager` inspecciona esos directorios,
los interpreta como paquetes duplicados y muestra avisos de ubicación
inconsistente. Si se necesita conservar una copia, debe moverse fuera de
`android-sdk`.

Si existe `android-sdk\cmdline-tools\latest` pero no contiene un
`sdkmanager.bat` válido, también hay que apartar ese directorio antes de volver
a ejecutar el instalador.

## Archivos generados

`android-sdk/`, `android-ndk/` y el directorio temporal
`android-ndk.installing/` no deben versionarse. Añada a `.gitignore` el
fragmento incluido junto a este paquete antes de retirar esos árboles del
repositorio.

El instalador usa un directorio temporal con nombre aleatorio para las
descargas. Las extracciones se realizan en la misma unidad que su destino para
evitar las limitaciones de `move` entre unidades de Windows. Si una extracción
se interrumpe, conserva `android-sdk\cmdline-tools.installing` o
`android-ndk.installing/` para que pueda inspeccionarse antes de borrarlo.

## Alcance de esta fase

Estos ficheros no modifican ni reescriben el historial Git. La retirada de los
SDK/NDK ya versionados y cualquier operación con `git filter-repo` deben
realizarse únicamente después de probar el instalador y compilar GEN para los
destinos Android previstos.
