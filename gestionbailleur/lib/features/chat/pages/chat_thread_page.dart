import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/design_system/spacing/ds_spacing.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../providers/chat_provider.dart';

/// Page de fil de discussion actif entre un Client et un Bailleur
class ChatThreadPage extends ConsumerStatefulWidget {
  final String conversationId;

  const ChatThreadPage({
    super.key,
    required this.conversationId,
  });

  @override
  ConsumerState<ChatThreadPage> createState() => _ChatThreadPageState();
}

class _ChatThreadPageState extends ConsumerState<ChatThreadPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AudioRecorder _audioRecorder = AudioRecorder();
  
  Set<String> _selectedMessages = {};
  bool _isSelectionMode = false;
  bool _isRecording = false;
  String? _recordingPath;
  DateTime? _recordingStartTime;
  Timer? _recordingTimer;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        ref
            .read(chatThreadProvider.notifier)
            .loadConversationAndMessages(widget.conversationId);
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _recordingTimer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _toggleMessageSelection(String messageId) {
    setState(() {
      if (_selectedMessages.contains(messageId)) {
        _selectedMessages.remove(messageId);
        if (_selectedMessages.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedMessages.add(messageId);
        _isSelectionMode = true;
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _selectedMessages.clear();
      _isSelectionMode = false;
    });
  }

  void _deleteSelectedMessages() {
    if (_selectedMessages.isEmpty) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer ${_selectedMessages.length} message(s)'),
        content: const Text('Êtes-vous sûr de vouloir supprimer ces messages ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              // Supprimer les messages sélectionnés un par un
              bool allDeleted = true;
              for (final messageId in _selectedMessages) {
                final success = await ref.read(chatThreadProvider.notifier).deleteMessage(messageId);
                if (!success) {
                  allDeleted = false;
                }
              }
              
              _exitSelectionMode();
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(allDeleted ? 'Messages supprimés' : 'Certains messages n\'ont pas pu être supprimés'),
                    backgroundColor: allDeleted ? Colors.green : Colors.orange,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _editMessage(MessageModel message) {
    _textController.text = message.content;
    _exitSelectionMode();
    
    // Afficher un dialogue pour confirmer l'édition
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le message'),
        content: TextField(
          controller: _textController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Entrez le nouveau message...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _textController.clear();
            },
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              if (_textController.text.trim().isEmpty) {
                Navigator.of(context).pop();
                _textController.clear();
                return;
              }
              
              Navigator.of(context).pop();
              
              // Mettre à jour le message localement (pas d'endpoint backend)
              final updatedMessage = message.copyWith(content: _textController.text.trim());
              final chatState = ref.read(chatThreadProvider);
              final updatedMessages = chatState.messages.map((m) {
                return m.id == message.id ? updatedMessage : m;
              }).toList();
              
              // Mettre à jour l'état
              ref.read(chatThreadProvider.notifier).state = chatState.copyWith(
                messages: updatedMessages,
              );
              
              _textController.clear();
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message modifié localement'), backgroundColor: Colors.green),
                );
              }
            },
            child: const Text('Modifier'),
          ),
        ],
      ),
    );
  }

  void _showMessageOptions(MessageModel message) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Modifier'),
              onTap: () {
                Navigator.pop(context);
                _editMessage(message);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Supprimer', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedMessages = {message.id};
                  _isSelectionMode = true;
                });
                _deleteSelectedMessages();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startRecording() async {
    try {
      // Demander la permission microphone
      final micStatus = await Permission.microphone.request();
      if (!micStatus.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permission microphone refusée'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Vérifier si l'enregistreur est disponible
      if (!await _audioRecorder.hasPermission()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permission microphone non accordée'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Obtenir le répertoire temporaire
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/voice_message_${DateTime.now().millisecondsSinceEpoch}.m4a';

      // Commencer l'enregistrement
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );

      setState(() {
        _isRecording = true;
        _recordingPath = path;
        _recordingStartTime = DateTime.now();
      });

      // Démarrer le timer pour mettre à jour la durée
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted && _isRecording) {
          setState(() {}); // Pour mettre à jour l'affichage de la durée
        }
      });

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur démarrage enregistrement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      _recordingTimer?.cancel();
      
      final path = await _audioRecorder.stop();
      
      if (path != null && mounted) {
        setState(() {
          _isRecording = false;
          _recordingPath = null;
          _recordingStartTime = null;
        });

        // TODO: Envoyer le fichier audio via le provider
        // Pour l'instant, simuler l'envoi
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Message vocal enregistré avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur arrêt enregistrement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _cancelRecording() {
    _recordingTimer?.cancel();
    _audioRecorder.stop();
    
    // Supprimer le fichier temporaire
    if (_recordingPath != null) {
      final file = File(_recordingPath!);
      if (file.existsSync()) {
        file.deleteSync();
      }
    }

    setState(() {
      _isRecording = false;
      _recordingPath = null;
      _recordingStartTime = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enregistrement annulé'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  String _getRecordingDuration() {
    if (_recordingStartTime == null) return '0:00';
    final duration = DateTime.now().difference(_recordingStartTime!);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _handleSendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();
    final success =
        await ref.read(chatThreadProvider.notifier).sendMessage(text);
    if (success) {
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chatThreadState = ref.watch(chatThreadProvider);
    final conversation = chatThreadState.conversation;

    return AppScaffold(
      title: _isSelectionMode
          ? '${_selectedMessages.length} sélectionné(s)'
          : (conversation != null
              ? conversation.otherParticipantName
              : 'Discussion'),
      showBackButton: true,
      onBackPressed: _isSelectionMode ? _exitSelectionMode : () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          context.go(AppConstants.routeChat);
        }
      },
      actions: [
        if (_isSelectionMode) ...[
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteSelectedMessages,
            tooltip: 'Supprimer',
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _exitSelectionMode,
            tooltip: 'Annuler',
          ),
        ] else if (conversation != null)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: theme.colorScheme.primary,
              backgroundImage: conversation.otherParticipantAvatar != null
                  ? CachedNetworkImageProvider(conversation.otherParticipantAvatar!)
                  : null,
              child: conversation.otherParticipantAvatar == null
                  ? Text(
                      conversation.otherParticipantName.isNotEmpty
                          ? conversation.otherParticipantName[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    )
                  : null,
            ),
          ),
      ],
      body: Column(
        children: [
          // Banner Logement Associé
          if (conversation != null)
            _buildPropertyHeaderBanner(context, conversation, theme),

          // Liste des messages
          Expanded(
            child: chatThreadState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : chatThreadState.errorMessage != null
                    ? _buildErrorWidget(theme, chatThreadState.errorMessage!)
                    : chatThreadState.messages.isEmpty
                        ? _buildEmptyMessagesWidget(theme)
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(DSSpacing.md),
                            itemCount: chatThreadState.messages.length,
                            itemBuilder: (context, index) {
                              final message = chatThreadState.messages[index];
                              return _buildMessageBubble(
                                  context, message, theme);
                            },
                          ),
          ),

          // Erreur d'envoi éventuelle
          if (chatThreadState.sendError != null)
            Container(
              color: theme.colorScheme.errorContainer,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: theme.colorScheme.error, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      chatThreadState.sendError!,
                      style: TextStyle(color: theme.colorScheme.error, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

          // Zone de saisie inférieure
          _buildInputBar(context, theme, chatThreadState.isSending),
        ],
      ),
    );
  }

  /// Banner du logement réel au-dessus de la discussion
  Widget _buildPropertyHeaderBanner(
      BuildContext context, ConversationModel conversation, ThemeData theme) {
    final property = conversation.property;

    return InkWell(
      onTap: () {
        context.go(
          AppConstants.routePropertyDetails.replaceFirst(':id', property.id),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          border: Border(
            bottom: BorderSide(
              color: theme.dividerColor.withValues(alpha: 0.5),
            ),
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: property.mainPhoto != null && property.mainPhoto!.isNotEmpty
                  ? Image.network(
                      property.mainPhoto!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey[300],
                        child: const Icon(Icons.home, size: 24),
                      ),
                    )
                  : Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey[300],
                      child: const Icon(Icons.home, size: 24),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title.isNotEmpty
                        ? property.title
                        : 'Logement concerné',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${property.district.isNotEmpty ? '${property.district}, ' : ''}${property.city.isNotEmpty ? property.city : ''}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              property.formattedPrice,
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const Icon(Icons.chevron_right, size: 18),
          ],
        ),
      ),
    );
  }

  /// Bulle de message (Envoyé vs Reçu)
  Widget _buildMessageBubble(
      BuildContext context, MessageModel message, ThemeData theme) {
    final isMe = message.isMe;
    final isSelected = _selectedMessages.contains(message.id);

    return GestureDetector(
      onLongPress: () {
        if (isMe) {
          _showMessageOptions(message);
        } else {
          _toggleMessageSelection(message.id);
        }
      },
      onTap: () {
        if (_isSelectionMode) {
          _toggleMessageSelection(message.id);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isSelectionMode && isSelected)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
            if (!isMe && message.senderAvatar != null) ...[
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CircleAvatar(
                  radius: 16,
                  backgroundImage: CachedNetworkImageProvider(message.senderAvatar!),
                  child: message.senderAvatar == null || message.senderAvatar!.isEmpty
                      ? Text(
                          message.senderName.isNotEmpty
                              ? message.senderName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        )
                      : null,
                ),
              ),
            ],
            if (!isMe && (message.senderAvatar == null || message.senderAvatar!.isEmpty)) ...[
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    message.senderName.isNotEmpty
                        ? message.senderName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary.withValues(alpha: 0.3)
                      : (isMe
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surfaceContainerHighest),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isMe ? 16 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 16),
                  ),
                  border: isSelected
                      ? Border.all(color: theme.colorScheme.primary, width: 2)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment:
                      isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    if (!isMe)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          message.senderName,
                          style: TextStyle(
                            color: isMe
                                ? theme.colorScheme.onPrimary.withValues(alpha: 0.8)
                                : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    Text(
                      message.content,
                      style: TextStyle(
                        color: isMe
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface,
                        fontSize: 14,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(message.createdAt),
                          style: TextStyle(
                            color: isMe
                                ? theme.colorScheme.onPrimary.withValues(alpha: 0.7)
                                : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            fontSize: 10,
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 4),
                          Icon(
                            message.isRead ? Icons.done_all : Icons.done,
                            size: 14,
                            color: message.isRead
                                ? Colors.lightBlueAccent
                                : theme.colorScheme.onPrimary.withValues(alpha: 0.7),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Barre de saisie inférieure
  Widget _buildInputBar(BuildContext context, ThemeData theme, bool isSending) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isRecording)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.fiber_manual_record, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Enregistrement: ${_getRecordingDuration()}',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Glissez vers la gauche pour annuler',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                GestureDetector(
                  onLongPressStart: (_) => _startRecording(),
                  onLongPressEnd: (_) => _stopRecording(),
                  onHorizontalDragEnd: (details) {
                    if (_isRecording && details.primaryVelocity != null && details.primaryVelocity! < 0) {
                      _cancelRecording();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isRecording 
                          ? Colors.red.withValues(alpha: 0.2)
                          : theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                      color: _isRecording ? Colors.red : theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 4,
                    minLines: 1,
                    enabled: !_isRecording,
                    decoration: InputDecoration(
                      hintText: _isRecording ? 'Enregistrement en cours...' : 'Écrivez votre message...',
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                    ),
                    onSubmitted: (_) => _handleSendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                if (!_isRecording)
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primary,
                    child: isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.send, color: Colors.white, size: 20),
                            onPressed: _handleSendMessage,
                          ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyMessagesWidget(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline,
                size: 64, color: theme.colorScheme.primary.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            const Text(
              'Aucun message pour le moment.',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Posez vos questions au bailleur concernant ce logement.',
              style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(ThemeData theme, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
          const SizedBox(height: 12),
          Text(error, style: TextStyle(color: theme.colorScheme.error)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(chatThreadProvider.notifier)
                  .loadConversationAndMessages(widget.conversationId);
            },
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
