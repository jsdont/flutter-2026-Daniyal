import 'package:flutter/material.dart';

import 'user.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: ListView(
        children: [
          ListTile(title: const Text('ID'), subtitle: Text('${user.id}')),
          ListTile(
            title: const Text('Username'),
            subtitle: Text(user.username),
          ),
          ListTile(title: const Text('Email'), subtitle: Text(user.email)),
          ListTile(
            title: const Text('Phone'),
            subtitle: Text(user.phone.isEmpty ? '—' : user.phone),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Website'),
            subtitle: Text(user.website ?? '—'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Address'),
            subtitle: Text(
              '${user.address.street}, ${user.address.suite}\n'
              '${user.address.city} ${user.address.zipcode}',
            ),
            isThreeLine: true,
          ),
          ListTile(
            title: const Text('Coordinates'),
            subtitle: Text('${user.address.geo.lat}, ${user.address.geo.lng}'),
          ),
          ListTile(
            title: const Text('Company'),
            subtitle: Text(user.company.name),
          ),
          ListTile(
            title: const Text('Catch phrase'),
            subtitle: Text(user.company.catchPhrase),
          ),
          ListTile(
            title: const Text('Business'),
            subtitle: Text(user.company.bs),
          ),
        ],
      ),
    );
  }
}
