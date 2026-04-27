# Что это?
Клиент мессенджера FER (пока только для Windows и Linux), написан на Flutter и Dart<br> (иишкой :3)

## Почему это так плохо?
Я первый раз в глаза флаттер вижу<br> *не судите строго*

---

## Как собрать?

### Перед сборкой:
Убедитесь что есть Flutter SDK([тут](https://docs.flutter.dev/install)), Git.
Для Windows также необходимы: Visual Studio Build Tools 2022 с workload Desktop development with C++([тут](https://aka.ms/vs/stable/vs_BuildTools.exe)).
Для Linux: clang, cmake, ninja-build, pkg-config, libgtk-3-dev, liblzma-dev, libstdc++-12-dev.

### Сборка
1. Клонирование
`git clone https://github.com/Katayo0/ferCLIENT`
`cd fer_client`

2. Установка Flutter зависимостей
`flutter pub get`

3.1. Сборка и запуск (Windows)
`flutter build windows --release`
Готовое приложение находится в папке: build/windows/x64/runner/Release/
Запустите fer_client.exe из папки сборки.

3.2 Сборка и запуск (Linux)
`flutter build linux --release`
Готовое приложение находится в папке: build/linux/x64/release/bundle/
Выполните ./fer_client из папки bundle.