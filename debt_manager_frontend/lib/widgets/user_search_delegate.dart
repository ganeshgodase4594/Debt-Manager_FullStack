import 'package:debt_manager_frontend/models/user.dart';
import 'package:debt_manager_frontend/providers/user_provider.dart';
import 'package:debt_manager_frontend/utils/constants.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class UserSearchDelegate extends SearchDelegate<User?> {
  final UserProvider userProvider;
  Timer? _debounceTimer;

  UserSearchDelegate({required this.userProvider});

  @override
  String get searchFieldLabel => 'Search users by name or username...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryPink,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white70),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child:
            query.isNotEmpty
                ? IconButton(
                  key: ValueKey('clear'),
                  icon: Icon(Icons.clear, color: Colors.white),
                  onPressed: () {
                    query = '';
                    userProvider.clearSearchResults();
                  },
                )
                : SizedBox.shrink(key: ValueKey('empty')),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back, color: Colors.white),
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
      return Container(
        color: Colors.grey[50],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search, size: 64, color: Colors.grey[400]),
              SizedBox(height: 16),
              Text(
                'Search Users',
                style: AppTextStyles.headline2.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Start typing to find users by name or username',
                style: AppTextStyles.body1.copyWith(color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Use debounced search to avoid calling during build
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: 300), () {
      if (query.isNotEmpty) {
        userProvider.searchUsers(query);
      }
    });

    return AnimatedBuilder(
      animation: userProvider,
      builder: (context, child) {
        if (userProvider.isSearching) {
          return Container(
            color: Colors.grey[50],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryPink,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Searching...',
                    style: AppTextStyles.body1.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (userProvider.searchResults.isEmpty) {
          return Container(
            color: Colors.grey[50],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_search, size: 64, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    'No users found',
                    style: AppTextStyles.headline2.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Try searching with a different name or username',
                    style: AppTextStyles.body1.copyWith(
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Container(
          color: Colors.grey[50],
          child: ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 8),
            itemCount: userProvider.searchResults.length,
            itemBuilder: (context, index) {
              final user = userProvider.searchResults[index];
              return AnimatedContainer(
                duration: Duration(milliseconds: 200),
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      close(context, user);
                    },
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.primaryPink,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryPink.withOpacity(
                                    0.3,
                                  ),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                user.fullName.substring(0, 1).toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.fullName,
                                  style: AppTextStyles.headline2.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.alternate_email,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '@${user.username}',
                                      style: AppTextStyles.body2.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                if (user.phoneNumber != null) ...[
                                  SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.phone,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        user.phoneNumber!,
                                        style: AppTextStyles.body2.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey[400],
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  void close(BuildContext context, User? result) {
    _debounceTimer?.cancel();
    super.close(context, result);
  }
}
