// import 'package:flutter/material.dart';
// import 'package:todo_app/features/ai/ai_service.dart';
// import 'package:todo_app/features/todo/presentation/screens/app_theme.dart';
//
// class DailyPlanCard extends StatelessWidget {
//   final List<PlannedTask> plan;
//   final VoidCallback onDismiss;
//   final VoidCallback onRegenerate;
//
//   const DailyPlanCard({
//     super.key,
//     required this.plan,
//     required this.onDismiss,
//     required this.onRegenerate,
//   });
//
//   Color _urgencyColor(String urgency) {
//     switch (urgency) {
//       case 'high':
//         return AppTheme.priorityHigh;
//       case 'medium':
//         return AppTheme.priorityMedium;
//       default:
//         return AppTheme.priorityLow;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final greeting =
//     plan.firstWhere((p) => p.isGreeting, orElse: () => const PlannedTask(
//       description: "Let's get things done today!",
//       reason: '',
//       urgency: 'greeting',
//       isGreeting: true,
//     ));
//     final tasks = plan.where((p) => !p.isGreeting).toList();
//
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(20),
//           gradient: const LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
//           ),
//           border: Border.all(color: AppTheme.accent.withOpacity(0.4)),
//           boxShadow: [
//             BoxShadow(
//               color: AppTheme.accent.withOpacity(0.15),
//               blurRadius: 20,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ── Header ──────────────────────────────────────────────
//             Padding(
//               padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
//               child: Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(7),
//                     decoration: BoxDecoration(
//                       color: AppTheme.accent.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: const Text('✨',
//                         style: TextStyle(fontSize: 16)),
//                   ),
//                   const SizedBox(width: 10),
//                   const Expanded(
//                     child: Text(
//                       'AI Daily Plan',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 15,
//                       ),
//                     ),
//                   ),
//                   // Regenerate
//                   IconButton(
//                     onPressed: onRegenerate,
//                     icon: const Icon(Icons.refresh_rounded,
//                         color: Colors.white54, size: 18),
//                     tooltip: 'Regenerate',
//                     visualDensity: VisualDensity.compact,
//                   ),
//                   // Dismiss
//                   IconButton(
//                     onPressed: onDismiss,
//                     icon: const Icon(Icons.close_rounded,
//                         color: Colors.white54, size: 18),
//                     visualDensity: VisualDensity.compact,
//                   ),
//                 ],
//               ),
//             ),
//
//             // ── Greeting ─────────────────────────────────────────────
//             Padding(
//               padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
//               child: Text(
//                 greeting.description,
//                 style: TextStyle(
//                   color: Colors.white.withOpacity(0.75),
//                   fontSize: 13,
//                   fontStyle: FontStyle.italic,
//                 ),
//               ),
//             ),
//
//             // Divider
//             Divider(
//                 height: 1,
//                 color: Colors.white.withOpacity(0.08)),
//
//             // ── Task list ─────────────────────────────────────────────
//             ...tasks.asMap().entries.map((entry) {
//               final i = entry.key;
//               final task = entry.value;
//               final color = _urgencyColor(task.urgency);
//               final isLast = i == tasks.length - 1;
//
//               return Column(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Rank bubble
//                         Container(
//                           width: 24,
//                           height: 24,
//                           decoration: BoxDecoration(
//                             color: color.withOpacity(0.2),
//                             shape: BoxShape.circle,
//                             border: Border.all(
//                                 color: color.withOpacity(0.5)),
//                           ),
//                           child: Center(
//                             child: Text(
//                               '${i + 1}',
//                               style: TextStyle(
//                                 color: color,
//                                 fontSize: 11,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         // Content
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment:
//                             CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 task.description,
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 13,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                               if (task.reason.isNotEmpty) ...[
//                                 const SizedBox(height: 3),
//                                 Text(
//                                   task.reason,
//                                   style: TextStyle(
//                                     color:
//                                     Colors.white.withOpacity(0.5),
//                                     fontSize: 11,
//                                   ),
//                                 ),
//                               ],
//                             ],
//                           ),
//                         ),
//                         // Urgency dot
//                         Container(
//                           margin: const EdgeInsets.only(top: 4),
//                           width: 7,
//                           height: 7,
//                           decoration: BoxDecoration(
//                             color: color,
//                             shape: BoxShape.circle,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   if (!isLast)
//                     Divider(
//                       height: 1,
//                       indent: 52,
//                       color: Colors.white.withOpacity(0.06),
//                     ),
//                 ],
//               );
//             }),
//
//             const SizedBox(height: 4),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ─── Loading state card ───────────────────────────────────────────────────────
//
// class DailyPlanLoadingCard extends StatefulWidget {
//   const DailyPlanLoadingCard({super.key});
//
//   @override
//   State<DailyPlanLoadingCard> createState() => _DailyPlanLoadingCardState();
// }
//
// class _DailyPlanLoadingCardState extends State<DailyPlanLoadingCard>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _controller;
//   late final Animation<double> _shimmer;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1200),
//     )..repeat(reverse: true);
//     _shimmer = Tween(begin: 0.3, end: 0.7).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
//     );
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
//       child: AnimatedBuilder(
//         animation: _shimmer,
//         builder: (_, __) => Container(
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(20),
//             gradient: const LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
//             ),
//             border: Border.all(
//                 color: AppTheme.accent.withOpacity(0.4)),
//           ),
//           child: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(7),
//                 decoration: BoxDecoration(
//                   color: AppTheme.accent
//                       .withOpacity(_shimmer.value),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: const Text('✨',
//                     style: TextStyle(fontSize: 16)),
//               ),
//               const SizedBox(width: 14),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Planning your day...',
//                       style: TextStyle(
//                         color: Colors.white
//                             .withOpacity(_shimmer.value + 0.3),
//                         fontWeight: FontWeight.bold,
//                         fontSize: 14,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       'Claude is prioritising your tasks',
//                       style: TextStyle(
//                         color: Colors.white.withOpacity(0.4),
//                         fontSize: 12,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(
//                 width: 18,
//                 height: 18,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2,
//                   color: AppTheme.accent
//                       .withOpacity(_shimmer.value + 0.3),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }