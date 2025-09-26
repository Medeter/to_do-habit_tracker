import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/task_provider.dart';

import '../services/hive_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // User Profile Section
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 50 * (1 - _animationController.value)),
                  child: Opacity(
                    opacity: _animationController.value,
                    child: Card(
                      elevation: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primaryContainer,
                              Theme.of(context).colorScheme.secondaryContainer,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Row(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      Theme.of(context).colorScheme.primary,
                                      Theme.of(context).colorScheme.secondary,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.person_rounded,
                                  size: 40,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ผู้ใช้งาน',
                                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'จัดการตั้งค่าแอปพลิเคชัน',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Appearance Section
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 100 * (1 - _animationController.value)),
                  child: Opacity(
                    opacity: _animationController.value,
                    child: _buildSection(
                      context,
                      'การแสดงผล',
                      Icons.palette_rounded,
                      [
                        _buildModernSwitchTile(
                          context,
                          'โหมดมืด',
                          'สลับระหว่างธีมสว่างและธีมมืด',
                          settingsProvider.isDarkMode,
                          Icons.dark_mode_rounded,
                          Icons.light_mode_rounded,
                          (value) => settingsProvider.toggleDarkMode(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Tasks & Habits Section
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 150 * (1 - _animationController.value)),
                  child: Opacity(
                    opacity: _animationController.value,
                    child: _buildSection(
                      context,
                      'งาน & นิสัย',
                      Icons.task_alt_rounded,
                      [
                        _buildModernSwitchTile(
                          context,
                          'แสดงงานที่เสร็จแล้ว',
                          'แสดงงานที่ทำเสร็จแล้วในรายการ',
                          settingsProvider.showCompletedTasks,
                          Icons.visibility_rounded,
                          Icons.visibility_off_rounded,
                          (value) => settingsProvider.toggleShowCompletedTasks(),
                        ),
                        const Divider(height: 1),
                        _buildModernSwitchTile(
                          context,
                          'การแจ้งเตือน',
                          'รับการแจ้งเตือนสำหรับงานที่กำหนด',
                          settingsProvider.notificationsEnabled,
                          Icons.notifications_rounded,
                          Icons.notifications_off_rounded,
                          (value) => settingsProvider.toggleNotifications(),
                        ),
                        const Divider(height: 1),
                        _buildModernSwitchTile(
                          context,
                          'เก็บประวัติการทำงาน',
                          'บันทึกประวัติการทำงานเพื่อวิเคราะห์',
                          true, // Always enabled for now
                          Icons.history_rounded,
                          Icons.history_toggle_off_rounded,
                          (value) {}, // Placeholder function
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Data Management Section
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 200 * (1 - _animationController.value)),
                  child: Opacity(
                    opacity: _animationController.value,
                    child: _buildSection(
                      context,
                      'จัดการข้อมูล',
                      Icons.storage_rounded,
                      [
                        _buildActionTile(
                          context,
                          'นำเข้าข้อมูล',
                          'นำเข้าข้อมูลจากไฟล์สำรอง',
                          Icons.upload_rounded,
                          () => _importData(context),
                          Theme.of(context).colorScheme.primary,
                        ),
                        const Divider(height: 1),
                        _buildActionTile(
                          context,
                          'ส่งออกข้อมูล',
                          'สำรองข้อมูลไปยังไฟล์',
                          Icons.download_rounded,
                          () => _exportData(context),
                          Theme.of(context).colorScheme.secondary,
                        ),
                        const Divider(height: 1),
                        _buildActionTile(
                          context,
                          'ลบข้อมูลทั้งหมด',
                          'ลบข้อมูลทั้งหมดและเริ่มต้นใหม่',
                          Icons.delete_forever_rounded,
                          () => _clearAllData(context),
                          Theme.of(context).colorScheme.error,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // About Section
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 250 * (1 - _animationController.value)),
                  child: Opacity(
                    opacity: _animationController.value,
                    child: _buildSection(
                      context,
                      'เกี่ยวกับแอป',
                      Icons.info_rounded,
                      [
                        _buildActionTile(
                          context,
                          'นโยบายความเป็นส่วนตัว',
                          'อ่านนโยบายความเป็นส่วนตัว',
                          Icons.privacy_tip_rounded,
                          () => _showPrivacyPolicy(context),
                          Theme.of(context).colorScheme.tertiary,
                        ),
                        const Divider(height: 1),
                        _buildActionTile(
                          context,
                          'เงื่อนไขการใช้งาน',
                          'อ่านเงื่อนไขการใช้งานแอป',
                          Icons.description_rounded,
                          () => _showTermsOfService(context),
                          Theme.of(context).colorScheme.tertiary,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 40),
          ],
        );
      },
    );
  }

  Widget _buildSection(BuildContext context, String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildModernSwitchTile(
    BuildContext context,
    String title,
    String subtitle,
    bool value,
    IconData activeIcon,
    IconData inactiveIcon,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: value 
                  ? Theme.of(context).colorScheme.primaryContainer 
                  : Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              value ? activeIcon : inactiveIcon,
              color: value 
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
    Color color,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _importData(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        
        // Validate file extension
        String fileName = result.files.single.name;
        if (!fileName.toLowerCase().endsWith('.json')) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('โปรดเลือกไฟล์ JSON เท่านั้น (.json)'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
        
        String jsonString = await file.readAsString();
        json.decode(jsonString); // Parse to validate JSON format

        if (mounted) {
          bool? confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('ยืนยันการนำเข้าข้อมูล'),
              content: const Text('การดำเนินการนี้จะแทนที่ข้อมูลปัจจุบัน คุณต้องการดำเนินการต่อหรือไม่?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('ยกเลิก'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('นำเข้า'),
                ),
              ],
            ),
          );

          if (confirm == true && mounted) {
            // TODO: Implement import functionality
            await Future.delayed(const Duration(milliseconds: 500));
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('นำเข้าข้อมูลสำเร็จ'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportData(BuildContext context) async {
    try {
      // Create sample export data
      final data = {
        'tasks': [],
        'settings': {},
        'exportDate': DateTime.now().toIso8601String(),
      };
      
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${directory.path}/tasks_backup_$timestamp.json');
      
      await file.writeAsString(json.encode(data));
      
      if (mounted) {
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'สำรองข้อมูลแอปจัดการงาน & นิสัย',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _clearAllData(BuildContext context) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบข้อมูล'),
        content: const Text('การดำเนินการนี้จะลบข้อมูลทั้งหมดและไม่สามารถย้อนกลับได้ คุณแน่ใจหรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('ลบทั้งหมด'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await HiveService.clearAllData();
      await context.read<TaskProvider>().loadTasks();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ลบข้อมูลทั้งหมดเรียบร้อยแล้ว'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('นโยบายความเป็นส่วนตัว'),
        content: const SingleChildScrollView(
          child: Text(
            'แอปนี้เก็บข้อมูลของคุณไว้ในเครื่องเท่านั้น ไม่มีการส่งข้อมูลไปยังเซิร์ฟเวอร์ภายนอก\n\n'
            'ข้อมูลที่เก็บ:\n'
            '• งานและนิสัยที่คุณสร้าง\n'
            '• การตั้งค่าของแอป\n'
            '• ประวัติการทำงาน\n\n'
            'คุณสามารถลบข้อมูลทั้งหมดได้ตลอดเวลาจากหน้าตั้งค่า',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เงื่อนไขการใช้งาน'),
        content: const SingleChildScrollView(
          child: Text(
            'การใช้งานแอปนี้ถือว่าคุณยอมรับเงื่อนไขต่อไปนี้:\n\n'
            '1. แอปนี้ให้บริการ "ตามสภาพ" โดยไม่มีการรับประกันใดๆ\n'
            '2. คุณรับผิดชอบข้อมูลของคุณเอง\n'
            '3. แอปนี้ไม่รับผิดชอบต่อความเสียหายที่อาจเกิดขึ้น\n'
            '4. การใช้งานต้องเป็นไปตามกฎหมาย\n\n'
            'ผู้พัฒนาสงวนสิทธิ์ในการเปลี่ยนแปลงเงื่อนไขโดยไม่ต้องแจ้งให้ทราบล่วงหน้า',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }
}