import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import 'new_user_screen.dart';
import 'user_detail_screen.dart';
import 'users_model.dart';
import 'widgets/loading_view.dart';
import 'widgets/status_view.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<UsersModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: model.loading
          ? const LoadingView()
          : switch (model.error) {
              null => RefreshIndicator(
                onRefresh: model.load,
                child: model.items.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(32),
                            child: Center(child: Text('No users yet')),
                          ),
                        ],
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 88),
                        itemCount: model.items.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final user = model.items[index];
                          return ListTile(
                            title: Text(user.name),
                            subtitle: Text(
                              '${user.email}\n${user.address.city}',
                            ),
                            isThreeLine: true,
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => UserDetailScreen(user: user),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              NoConnectionException() => StatusView(
                message: 'No connection. Check your internet and try again.',
                onRetry: model.load,
              ),
              NotFoundException() => const StatusView(
                message: 'Users not found.',
              ),
              UnauthorizedException() => const StatusView(
                message: 'You do not have access to these users.',
              ),
              ServerException(:final status) => StatusView(
                message: 'Server error ($status). Please try again.',
                onRetry: model.load,
              ),
              BadResponseException() => const StatusView(
                message: 'Could not read the server response.',
              ),
            },
      floatingActionButton: FloatingActionButton.extended(
        onPressed: model.loading || model.saving
            ? null
            : () => Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => const NewUserScreen()),
              ),
        icon: const Icon(Icons.person_add),
        label: const Text('New user'),
      ),
    );
  }
}
