import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/design_system/spacing/ds_spacing.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../authentication/providers/auth_provider.dart';
import '../models/conversation_model.dart';
import '../providers/chat_provider.dart';
import 'chat_thread_page.dart';

/// Page principale de gestion des conversations réelles (Messagerie)
class MessagesPage extends ConsumerStatefulWidget {
  final String? initialConversationId;

  const MessagesPage({
    super.key,
    this.initialConversationId,
  });

  @override
  ConsumerState<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends ConsumerState<MessagesPage> {
  String? _selectedConversationId;

  @override
  void initState() {
    super.initState();
    _selectedConversationId = widget.initialConversationId;
    Future.microtask(() {
      if (mounted) {
        ref.read(messagesProvider.notifier).loadConversations();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final messagesState = ref.watch(messagesProvider);

    return AppScaffold(
      title: 'Messagerie',
      showBackButton: true,
      onBackPressed: () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          context.go(AppConstants.routeHome);
        }
      },
      actions: [
        IconButton(
          icon: const Icon(Icons.home_outlined),
          tooltip: 'Accueil',
          onPressed: () => context.go(AppConstants.routeHome),
        ),
        const SizedBox(width: 8),
      ],
      body: !authState.estAuthentifie
          ? _buildUnauthenticatedState(context, theme)
          : LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop =
                    constraints.maxWidth > AppConstants.breakpointTablet;

                if (isDesktop) {
                  return _buildDesktopSplitView(
                      context, theme, messagesState, isDesktop);
                } else {
                  return _buildMobileListView(context, theme, messagesState);
                }
              },
            ),
    );
  }

  /// Vue Responsive Split-Screen pour Web / Desktop
  Widget _buildDesktopSplitView(BuildContext context, ThemeData theme,
      MessagesState messagesState, bool isDesktop) {
    final conversations = messagesState.conversations;
    if (_selectedConversationId == null && conversations.isNotEmpty) {
      _selectedConversationId = conversations.first.id;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final sidebarWidth = constraints.maxWidth > 1200 ? 400.0 : 360.0;
        
        return Row(
          children: [
            // Panneau gauche : Liste des conversations
            SizedBox(
              width: sidebarWidth,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: theme.dividerColor.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                child: _buildConversationsList(
                  context,
                  theme,
                  messagesState,
                  isDesktop: true,
                ),
              ),
            ),

            // Panneau droit : Discussion sélectionnée
            Expanded(
              child: _selectedConversationId != null
                  ? ChatThreadPage(
                      key: ValueKey(_selectedConversationId),
                      conversationId: _selectedConversationId!,
                    )
                  : _buildNoConversationSelectedPlaceholder(theme),
            ),
          ],
        );
      },
    );
  }

  /// Vue Mobile : Liste des conversations full-width
  Widget _buildMobileListView(
      BuildContext context, ThemeData theme, MessagesState messagesState) {
    return _buildConversationsList(
      context,
      theme,
      messagesState,
      isDesktop: false,
    );
  }

  /// Widget générique affichant la liste des conversations réelles
  Widget _buildConversationsList(
      BuildContext context, ThemeData theme, MessagesState messagesState,
      {required bool isDesktop}) {
    if (messagesState.isLoading && messagesState.conversations.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (messagesState.errorMessage != null &&
        messagesState.conversations.isEmpty) {
      return _buildErrorState(context, theme, messagesState.errorMessage!);
    }

    if (messagesState.conversations.isEmpty) {
      return _buildEmptyState(context, theme);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(messagesProvider.notifier)
            .loadConversations(forceRefresh: true);
      },
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: DSSpacing.sm),
        itemCount: messagesState.conversations.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          indent: 72,
          color: theme.dividerColor.withValues(alpha: 0.3),
        ),
        itemBuilder: (context, index) {
          final conversation = messagesState.conversations[index];
          final isSelected = isDesktop && conversation.id == _selectedConversationId;

          return _buildConversationTile(
            context,
            theme,
            conversation,
            isSelected: isSelected,
            isDesktop: isDesktop,
          );
        },
      ),
    );
  }

  /// Element de liste d'une conversation
  Widget _buildConversationTile(
      BuildContext context, ThemeData theme, ConversationModel conversation,
      {required bool isSelected, required bool isDesktop}) {
    final lastMsg = conversation.lastMessage;
    final hasUnread = conversation.unreadCount > 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 350;
        
        return ListTile(
          selected: isSelected,
          selectedTileColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          contentPadding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 12 : 16, 
            vertical: 8
          ),
          leading: Stack(
            children: [
              CircleAvatar(
                radius: isSmallScreen ? 22 : 26,
                backgroundColor: theme.colorScheme.primary,
                backgroundImage: conversation.otherParticipantAvatar != null
                    ? CachedNetworkImageProvider(conversation.otherParticipantAvatar!)
                    : null,
                child: conversation.otherParticipantAvatar == null
                    ? Text(
                        conversation.otherParticipantName.isNotEmpty
                            ? conversation.otherParticipantName[0].toUpperCase()
                            : 'U',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 16 : 18,
                        ),
                      )
                    : null,
              ),
              if (hasUnread)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${conversation.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  conversation.otherParticipantName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600,
                    fontSize: isSmallScreen ? 15 : 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                _formatDate(conversation.lastMessageAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: hasUnread
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                  fontSize: isSmallScreen ? 11 : 12,
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Text(
                '${conversation.property.title} • ${conversation.property.formattedPrice}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                  fontSize: isSmallScreen ? 12 : 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                lastMsg != null ? lastMsg.content : 'Aucun message',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: hasUnread
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                  fontSize: isSmallScreen ? 13 : 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          onTap: () {
            if (isDesktop) {
              setState(() {
                _selectedConversationId = conversation.id;
              });
            } else {
              context.push('/chat/${conversation.id}');
            }
          },
          trailing: PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            onSelected: (value) {
              _handleConversationAction(context, conversation, value);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'mark_read',
                child: Row(
                  children: [
                    Icon(Icons.mark_email_read, size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    const Text('Marquer comme lu'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'archive',
                child: Row(
                  children: [
                    Icon(Icons.archive, size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    const Text('Archiver'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: Colors.red),
                    const SizedBox(width: 12),
                    const Text('Supprimer', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Visiteur non connecté
  Widget _buildUnauthenticatedState(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 64,
              color: theme.colorScheme.primary.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Connectez-vous pour accéder à vos messages',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Échangez directement avec les propriétaires et les candidats concernant vos annonces.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go(AppConstants.routeLogin),
              icon: const Icon(Icons.login),
              label: const Text('Se connecter'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Empty State officiel
  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              "Vous n'avez encore aucune conversation.",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Consultez les annonces de logements et cliquez sur 'Contacter le bailleur' pour échanger.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go(AppConstants.routeSearch),
              icon: const Icon(Icons.search),
              label: const Text('Découvrir les logements'),
            ),
          ],
        ),
      ),
    );
  }

  /// Erreur
  Widget _buildErrorState(
      BuildContext context, ThemeData theme, String errorMsg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_outlined,
                size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Impossible de charger vos conversations',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(errorMsg, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                ref
                    .read(messagesProvider.notifier)
                    .loadConversations(forceRefresh: true);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoConversationSelectedPlaceholder(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat,
              size: 80, color: theme.colorScheme.primary.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            'Sélectionnez une conversation',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choisissez une conversation dans la liste de gauche pour afficher les messages.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 60) {
      return 'Il y a ${diff.inMinutes < 1 ? 1 : diff.inMinutes} min';
    } else if (diff.inHours < 24) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays < 7) {
      return 'Il y a ${diff.inDays} j';
    }
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  void _handleConversationAction(BuildContext context, ConversationModel conversation, String action) {
    switch (action) {
      case 'mark_read':
        ref.read(messagesProvider.notifier).markAsRead(conversation.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conversation marquée comme lue'), backgroundColor: Colors.green),
        );
        break;
      case 'archive':
        ref.read(messagesProvider.notifier).archiveConversation(conversation.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conversation archivée'), backgroundColor: Colors.green),
        );
        break;
      case 'delete':
        _showDeleteConfirmationDialog(context, conversation);
        break;
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, ConversationModel conversation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la conversation'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette conversation ? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(messagesProvider.notifier).deleteConversation(conversation.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Conversation supprimée'), backgroundColor: Colors.green),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
