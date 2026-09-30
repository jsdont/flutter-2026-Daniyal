import 'package:flutter/material.dart';

import 'contact_card.dart';
import 'contacts.dart';

class ContactList extends StatelessWidget {
  const ContactList({super.key});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Text(
          '${contacts.length} contacts',
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ),
      Expanded(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: contacts.length,
          itemBuilder: (context, index) =>
              ContactCard(contact: contacts[index]),
          separatorBuilder: (context, index) => const Divider(),
        ),
      ),
    ],
  );
}
