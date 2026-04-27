# Что это?

Клиент мессенджера [FER](https://github.com/jarymor-ux/fer) (пока только для Windows и Linux), написан на Flutter и Dart<br> *иишкой :3*

## Почему это так плохо?
Я первый раз в глаза флаттер вижу<br> *не судите строго*


## Как собрать?

### Перед сборкой:
Убедитесь что есть [Flutter SDK](https://docs.flutter.dev/install), Git.

Для Windows также необходимы: [Visual Studio Build Tools 2022 с workload Desktop development with C++](https://aka.ms/vs/stable/vs_BuildTools.exe).

Для Linux: clang, cmake, ninja-build, pkg-config, libgtk-3-dev, liblzma-dev, libstdc++-12-dev.

### Подготовка
Клонирование

`git clone https://github.com/Katayo0/ferCLIENT`<br>
`cd fer_client`

Установка Flutter зависимостей

`flutter pub get`
### Сборка

**Windows**

`flutter build windows --release`

Готовое приложение находится в папке: build/windows/x64/runner/Release/

Запустите fer_client.exe из папки сборки.

**Linux**

`flutter build linux --release`

Готовое приложение находится в папке: build/linux/x64/release/bundle/

Выполните ./fer_client из папки bundle.
