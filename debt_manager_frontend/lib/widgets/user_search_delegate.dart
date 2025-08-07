import 'package:debt_manager_frontend/models/user.dart';
import 'package:debt_manager_frontend/providers/user_provider.dart';
import 'package:debt_manager_frontend/utils/constants.dart';
import 'package:flutter/material.dart';

class UserSearchDelegate extends SearchDelegate<User?> {
  final UserProvider userProvider;

  UserSearchDelegate({required this.userProvider});

  @override
  String get searchFieldLabel => 'Search users...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          userProvider.clearSearchResults();
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Center(
        child: Text(
          'Start typing to search users',
          style: AppTextStyles.body1.copyWith(color: Colors.grey[600]),
        ),
      );
    }

    userProvider.searchUsers(query);

    return AnimatedBuilder(
      animation: userProvider,
      builder: (context, child) {
        if (userProvider.isSearching) {
          return Center(child: CircularProgressIndicator());
        }

        if (userProvider.searchResults.isEmpty) {
          return Center(
            child: Text(
              'No users found',
              style: AppTextStyles.body1.copyWith(color: Colors.grey[600]),
            ),
          );
        }

        return ListView.builder(
          itemCount: userProvider.searchResults.length,
          itemBuilder: (context, index) {
            final user = userProvider.searchResults[index];
            return ListTile(
              leading: CircleAvatar(
                child: Text(user.fullName.substring(0, 1).toUpperCase()),
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
              ),
              title: Text(user.fullName),
              subtitle: Text('@${user.username}'),
              onTap: () {
                close(context, user);
              },
            );
          },
        );
      },
    );
  }
}
