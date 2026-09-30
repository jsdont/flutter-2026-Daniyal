# Practice 5 — A Screen That Never Overflows

Отдельный Flutter-проект с 20 контактами из задания.

## Запуск

Из этой папки:

```powershell
flutter pub get
flutter run
```

Выбери Android-эмулятор или другое доступное устройство. Для браузера: `flutter run -d chrome`.

## Файлы

- `lib/main.dart` — запуск, две темы, Scaffold; 38 строк.
- `lib/contacts.dart` — модель и исходные 20 контактов.
- `lib/contact_card.dart` — карточка, Expanded и счётчик на Stack.
- `lib/contact_list.dart` — заголовок и ListView.separated внутри Expanded.
- `test/widget_test.dart` — проверки размеров, прокрутки, тем и счётчиков.

Все собственные виджеты — StatelessWidget. Единственный исходный цвет задан константой `seedColor` в main.dart. Остальные цвета и стили берутся из темы.

## Проверки и эксперименты

Окружение: Flutter 3.47.2, Dart 3.13.2; Android Medium Phone API 36.1, 1080 × 2400, density 420.

- Приложение запущено через `flutter run` на Android-эмуляторе.
- На эмуляторе проверены обе системные темы и замена seedColor на Colors.teal; в финале возвращён Colors.deepPurple. В горизонтальной ориентации длинное имя помещается в одну строку.
- Без Expanded вокруг текста получена ошибка `A RenderFlex overflowed by 172 pixels on the right`. Число зависит от ширины экрана и шрифта. Expanded возвращён.
- Без Expanded вокруг списка получена ошибка `Vertical viewport was given unbounded height` в Flutter widget test. Viewport получает неограниченную высоту от Column; Expanded задаёт ему оставшуюся высоту.
- В том же тесте проверен shrinkWrap: true без Expanded: вместо unbounded height возникло переполнение Column на 1292 пикселя вниз. Вернули Expanded и убрали shrinkWrap.
- Автотесты проверяют узкий экран 320 × 700, горизонтальный 800 × 400 и масштаб текста 1×/2×; прокрутку всех 20 контактов и возврат к началу; системные темы и отсутствие счётчика при unread = 0.
- Между 20 карточками 19 разделителей; после последней разделителя нет.
- Итог: `flutter analyze` — No issues found; `flutter test` — 3 теста пройдены; `dart format .` выполнен.

Скриншоты находятся в корне учебного репозитория, на уровень выше проекта:

- `../screenshot_light.png` — готовый экран в светлой системной теме.
- `../screenshot_dark.png` — готовый экран в тёмной системной теме.
- `../stack_swapped.png` — эксперимент: Positioned со счётчиком стоит перед аватаром, поэтому аватар рисуется поверх него. В итоговом коде правильный порядок восстановлен.

```powershell
dart format .
flutter analyze
flutter test
```

Ключевое правило: constraints go down, sizes go up, parent sets position.

Справка: [ограничения Flutter](https://docs.flutter.dev/ui/layout/constraints), [темы](https://docs.flutter.dev/cookbook/design/themes).
