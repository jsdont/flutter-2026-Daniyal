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
