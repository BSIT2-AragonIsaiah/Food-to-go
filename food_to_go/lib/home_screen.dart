import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'account_type.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.email,
    required this.accountType,
  });

  final String email;
  final AccountType accountType;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSigningOut = false;

  Future<void> _signOut() async {
    setState(() => _isSigningOut = true);
    try {
      await Supabase.instance.client.auth.signOut();
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } on Exception catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Unable to log out: $error')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSigningOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isRegular = widget.accountType == AccountType.regular;
    final isFoodStall = widget.accountType == AccountType.foodStall;
    final title = switch (widget.accountType) {
      AccountType.regular => 'Your campus food, made easy.',
      AccountType.foodStall => 'Manage your food stall.',
      AccountType.admin => 'Administration dashboard',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food to Go'),
        leading: const Icon(Icons.restaurant_menu),
        actions: [
          IconButton(
            tooltip: 'Log out',
            onPressed: _isSigningOut ? null : _signOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Signed in as ${widget.email}',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.restaurant_menu,
                          size: 32,
                          color: colors.onPrimary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isRegular
                              ? 'Find your next meal'
                              : isFoodStall
                              ? 'Your stall'
                              : 'Food to Go overview',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: colors.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isRegular
                              ? 'Browse food stalls currently available on campus.'
                              : isFoodStall
                              ? 'Your menu and incoming orders will be available here.'
                              : 'Platform management tools will be available here.',
                          style: TextStyle(
                            color: colors.onPrimary.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  if (isRegular) ...[
                    Text(
                      'Available stalls',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      color: colors.surface,
                      child: const ListTile(
                        leading: Icon(Icons.storefront_outlined),
                        title: Text('No stalls available yet'),
                        subtitle: Text(
                          'Available food stalls will appear here.',
                        ),
                      ),
                    ),
                  ] else ...[
                    Text(
                      isFoodStall ? 'Incoming orders' : 'Management',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      color: colors.surface,
                      child: ListTile(
                        leading: const Icon(Icons.receipt_long_outlined),
                        title: Text(
                          isFoodStall
                              ? 'No incoming orders'
                              : 'No management tools yet',
                        ),
                        subtitle: Text(
                          isFoodStall
                              ? 'New customer orders will show up here.'
                              : 'Admin tools will be added here.',
                        ),
                      ),
                    ),
                  ],
                  if (_isSigningOut) ...[
                    const SizedBox(height: 20),
                    const Center(child: CircularProgressIndicator()),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
