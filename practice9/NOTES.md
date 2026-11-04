# Practice 9

## Level 1

The cart is stored in Shell above MaterialApp. BooksScreen and CartScreen
get the list and callbacks from Shell.

Adding the total to the badge changed 2 constructors: BooksScreen in
lib/books_screen.dart and CartBadge in lib/cart_badge.dart. I also changed
lib/main.dart to calculate the total and pass it to BooksScreen.

One Add press produced 7 log lines: 1 BooksScreen build and 6 row lines.
This was measured in a widget test with all six books visible. Adding two
books, removing one on the Cart screen and returning to Books also passed.

## Level 2

The model was checked before creating a screen in a test. After adding the
first two books, trying the first book again and removing it, the output was:

```text
1 items, 3100 ₸
```

Trying cart.items.add(books[0]) gave:

```text
Unsupported operation: Cannot add to an unmodifiable list
```

Cart imports foundation.dart and the Book model. It does not need a context
or any Material widgets. Duplicate books are rejected by add.

## Level 3

ChangeNotifierProvider creates one Cart above Shell and MaterialApp.
The screens no longer receive a cart or callbacks through constructors.

Using watch in an onPressed callback gave this error in a test:

```text
Tried to listen to a value exposed with provider, from outside of the widget tree.
```

Provider suggested Provider.of<Cart>(context, listen: false).
The shorter version used in the app is context.read<Cart>().

Using read in build gave no error. The test badge still showed 0 after the
model count became 1. It read the value once but did not subscribe.
These broken versions were only used for the checks.

## Level 4

Rebuilds were counted from debugPrint in widget tests. The initial build and
route animations were excluded. This was not a DevTools counter recording.

| Badge subscription | Three quantity increases | Remove one book |
| --- | --- | --- |
| watch | 3 builds | 1 build |
| select on count | 0 builds | 1 build |

The final badge uses select on the number of different books. Its price is
in a separate small widget, so the price can update without rebuilding
the count. BookRow selects only whether its own book is in the cart.

With watch temporarily placed in BooksScreen, each + tap on the Cart route
rebuilt BooksScreen once and all 6 rows. With the final code, three + taps
produced 0 BooksScreen builds and 0 row builds.

The total uses Consumer with a const TotalLabel passed as child. Only the
value needs to change when the cart changes.

## Where does it live?

- Cart: provided, because both routes and the badge use it.
- Search text: ephemeral, because only BooksScreen needs it.
- Total expanded or collapsed: ephemeral, kept by the ExpansionTile on CartScreen.
- Theme mode with a dark-mode switch: lifted above MaterialApp, because it affects the whole app.

## Final checks

- Add shows a SnackBar only when the model returns true.
- Clear cart opens a dialog. Cancel keeps the items; Clear removes them.
- dart format . and flutter analyze completed without issues.
- Model, search, quantity, navigation, removal and clear checks passed.
- flutter run -d web-server opened the app in a browser.
- screenshot_books.png shows 2 books and 7300 ₸.
- screenshot_cart.png shows the first book at ×2 and a total of 11500 ₸.
