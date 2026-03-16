// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:todo_app/features/todo/data/models/todo_model.dart';
//
// class AiService {
//   AiService._();
//   static final instance = AiService._();
//
//   // ── Get your free key at: https://aistudio.google.com ───────────────────
//   static const _apiKey = 'YOUR_GEMINI_API_KEY_HERE';
//   static const _model = 'gemini-2.0-flash';
//   static const _baseUrl =
//       'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent';
//
//   // ── Daily Planning ────────────────────────────────────────────────────────
//
//   Future<List<PlannedTask>> planDay(List<TodoModel> todos) async {
//     final incomplete = todos.where((t) => !t.isComplete).toList();
//     if (incomplete.isEmpty) return [];
//
//     final now = DateTime.now();
//     final taskList = incomplete.map((t) {
//       final due = t.dueDate;
//       String dueStr = 'No due date';
//       if (due != null) {
//         final diff = due.difference(now).inDays;
//         if (diff < 0)       dueStr = 'OVERDUE by ${-diff} day(s)';
//         else if (diff == 0) dueStr = 'Due TODAY';
//         else if (diff == 1) dueStr = 'Due TOMORROW';
//         else                dueStr = 'Due in $diff days';
//       }
//       final priority =
//       t.priority == 1 ? 'High' : t.priority == 2 ? 'Medium' : 'Low';
//       return '- "${t.description}" | Priority: $priority | $dueStr';
//     }).join('\n');
//
//     final prompt = '''
// You are a productivity assistant. The user has the following tasks:
//
// $taskList
//
// Today is ${_formatDate(now)}.
//
// Return a JSON object with this exact structure — no markdown, no code fences, just raw JSON:
// {
//   "greeting": "A short warm greeting (max 12 words)",
//   "plan": [
//     {
//       "description": "exact task description as given",
//       "reason": "1 short sentence why this should be done first/next (max 12 words)",
//       "urgency": "high"
//     }
//   ]
// }
//
// Rules:
// - urgency must be exactly one of: "high", "medium", "low"
// - Include ALL tasks ranked by priority
// - Keep reasons concise and motivating
// - Do not wrap in markdown or code fences
// ''';
//
//     final response = await _call(prompt);
//     if (response == null) return [];
//
//     try {
//       // Strip any accidental markdown fences Gemini may add
//       final clean = response
//           .replaceAll('```json', '')
//           .replaceAll('```', '')
//           .trim();
//       final data = jsonDecode(clean) as Map<String, dynamic>;
//       final plan = data['plan'] as List<dynamic>;
//       return [
//         PlannedTask(
//           description: data['greeting'] as String,
//           reason: '',
//           urgency: 'greeting',
//           isGreeting: true,
//         ),
//         ...plan.map((p) => PlannedTask(
//           description: p['description'] as String,
//           reason: p['reason'] as String,
//           urgency: p['urgency'] as String,
//         )),
//       ];
//     } catch (_) {
//       return [];
//     }
//   }
//
//   // ── Session Coach ─────────────────────────────────────────────────────────
//
//   Future<String?> getCoachMessage({
//     required String sessionName,
//     required int elapsedMinutes,
//     required int totalMinutes,
//     required String focusType,
//   }) async {
//     final prompt =
//         'You are a focus coach. The user paused their "$focusType" session '
//         'called "$sessionName". They have been going for $elapsedMinutes '
//         'minutes out of a planned $totalMinutes minutes. '
//         'Write ONE short, warm, motivating message (max 20 words) to '
//         'encourage them to resume. No quotes. Just the message.';
//     return await _call(prompt);
//   }
//
//   // ── Task Breakdown ────────────────────────────────────────────────────────
//
//   Future<List<String>> breakdownTask(String taskDescription) async {
//     final prompt = '''
// Break this task into 3-6 specific, actionable subtasks:
// "$taskDescription"
//
// Return ONLY a raw JSON array of strings, no markdown, no code fences:
// ["subtask 1", "subtask 2", "subtask 3"]
//
// Each subtask should be short (max 8 words) and immediately actionable.
// ''';
//     final response = await _call(prompt);
//     if (response == null) return [];
//     try {
//       final clean = response
//           .replaceAll('```json', '')
//           .replaceAll('```', '')
//           .trim();
//       final list = jsonDecode(clean) as List<dynamic>;
//       return list.map((e) => e as String).toList();
//     } catch (_) {
//       return [];
//     }
//   }
//
//   // ── Natural Language Parser ───────────────────────────────────────────────
//
//   Future<ParsedTask?> parseNaturalLanguage(String input) async {
//     final now = DateTime.now();
//     final prompt = '''
// Parse this task input into structured fields. Today is ${_formatDate(now)}.
//
// Input: "$input"
//
// Return ONLY raw JSON (no markdown, no code fences):
// {
//   "description": "clean task description",
//   "priority": 2,
//   "dueDate": "YYYY-MM-DD or null",
//   "reminderTime": "HH:MM or null"
// }
//
// Priority: 1=high, 2=medium, 3=low. Infer from urgency words.
// dueDate: infer from "tomorrow", "Friday", "next week", specific dates, etc.
// reminderTime: 24h format if a time is mentioned, else null.
// For null values write the word null not a string "null".
// ''';
//     final response = await _call(prompt);
//     if (response == null) return null;
//     try {
//       final clean = response
//           .replaceAll('```json', '')
//           .replaceAll('```', '')
//           .trim();
//       final data = jsonDecode(clean) as Map<String, dynamic>;
//
//       DateTime? dueDate;
//       DateTime? reminderTime;
//
//       if (data['dueDate'] != null && data['dueDate'] != 'null') {
//         dueDate = DateTime.tryParse(data['dueDate'] as String);
//       }
//       if (data['reminderTime'] != null &&
//           data['reminderTime'] != 'null' &&
//           dueDate != null) {
//         final parts = (data['reminderTime'] as String).split(':');
//         if (parts.length == 2) {
//           reminderTime = DateTime(
//             dueDate.year, dueDate.month, dueDate.day,
//             int.parse(parts[0]), int.parse(parts[1]),
//           );
//         }
//       }
//
//       return ParsedTask(
//         description: data['description'] as String,
//         priority: (data['priority'] as num).toInt(),
//         dueDate: dueDate,
//         reminderTime: reminderTime,
//       );
//     } catch (_) {
//       return null;
//     }
//   }
//
//   // ── Core HTTP ─────────────────────────────────────────────────────────────
//
//   Future<String?> _call(String prompt) async {
//     try {
//       final uri = Uri.parse('$_baseUrl?key=$_apiKey');
//       final response = await http.post(
//         uri,
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'contents': [
//             {
//               'parts': [
//                 {'text': prompt}
//               ]
//             }
//           ],
//           'generationConfig': {
//             'temperature': 0.4,      // lower = more consistent JSON
//             'maxOutputTokens': 1000,
//           },
//         }),
//       );
//
//       if (response.statusCode != 200) return null;
//
//       final data = jsonDecode(response.body) as Map<String, dynamic>;
//       final candidates = data['candidates'] as List<dynamic>;
//       if (candidates.isEmpty) return null;
//
//       final content =
//       candidates.first['content'] as Map<String, dynamic>;
//       final parts = content['parts'] as List<dynamic>;
//       return (parts.first as Map<String, dynamic>)['text'] as String?;
//     } catch (_) {
//       return null;
//     }
//   }
//
//   String _formatDate(DateTime d) =>
//       '${d.year}-${d.month.toString().padLeft(2, '0')}-'
//           '${d.day.toString().padLeft(2, '0')}';
// }
//
// // ─── Data models ──────────────────────────────────────────────────────────────
//
// class PlannedTask {
//   final String description;
//   final String reason;
//   final String urgency;
//   final bool isGreeting;
//
//   const PlannedTask({
//     required this.description,
//     required this.reason,
//     required this.urgency,
//     this.isGreeting = false,
//   });
// }
//
// class ParsedTask {
//   final String description;
//   final int priority;
//   final DateTime? dueDate;
//   final DateTime? reminderTime;
//
//   const ParsedTask({
//     required this.description,
//     required this.priority,
//     this.dueDate,
//     this.reminderTime,
//   });
// }