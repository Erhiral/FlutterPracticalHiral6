import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:hiralfutterpractical/models/event_session.dart';

class EventService {
  static const String _url = 'https://www.kuwaiterp.com/ERPMobileAPI/api/event/GetAllBookedEventSessionList/78/79835';

  static Future<List<EventSession>> fetchSessions() async {
    final resp = await http.get(Uri.parse(_url));
    if (kDebugMode) {
      debugPrint('EventService.fetchSessions: status=${resp.statusCode}');
      debugPrint('EventService.fetchSessions: bodyBytes=${resp.bodyBytes.length}');
    }
    if (resp.statusCode != 200) {
      throw Exception('Failed to load sessions: ${resp.statusCode}');
    }

    // Some APIs might return UTF-8/UTF-16; ensure proper decode
    final body = utf8.decode(resp.bodyBytes);

    // 1) Try JSON: structure { "Data": [ {..session..}, ... ], ... }
    try {
      final decoded = json.decode(body);
      if (decoded is Map && decoded['Data'] is List) {
        final List data = decoded['Data'] as List;
        final sessions = <EventSession>[];
        for (final item in data) {
          if (item is Map) {
            int? id = _asInt(item['EventSessionId']);
            DateTime? sessionDate = _asDate(item['EventSessionDate']);
            DateTime? endDateTime = _asDate(item['EndDateTime']);
            final isAvailable = _asInt(item['IsAvailable']) == 1;
            final isNotAttended = _asInt(item['IsNotAttended']) == 1;
            final isBooked = _asInt(item['IsBooked']) == 1;
            final isCanceled = _asInt(item['IsCanceled']) == 1;
            final isClassSessionFull = _asInt(item['IsClassSessionFull']) == 1;

            if (id != null && sessionDate != null) {
              sessions.add(EventSession(
                eventSessionId: id,
                eventSessionDate: sessionDate,
                endDateTime: endDateTime,
                isAvailable: isAvailable,
                isNotAttended: isNotAttended,
                isBooked: isBooked,
                isCanceled: isCanceled,
                isClassSessionFull: isClassSessionFull,
              ));
            }
          }
        }
        if (kDebugMode) {
          debugPrint('EventService.fetchSessions: parsed JSON sessions=${sessions.length}');
        }
        return sessions;
      }
    } catch (_) {
      // Not JSON; fall back to XML
    }

    // 2) Fallback: XML parsing (original implementation)
    xml.XmlDocument doc;
    try {
      doc = xml.XmlDocument.parse(body);
    } catch (e) {
      // Handle cases like: multiple top-level nodes or stray XML declarations
      var cleaned = body.replaceAll(RegExp(r"<\?xml[^>]*>"), '').trim();
      final wrapped = '<root>$cleaned</root>';
      try {
        doc = xml.XmlDocument.parse(wrapped);
      } catch (e2) {
        throw Exception('XML parse failed: $e2');
      }
    }

    final items = <xml.XmlElement>[];
    for (final node in doc.findAllElements('*')) {
      final hasId = node.findElements('*').any((e) => e.name.local.toLowerCase() == 'eventsessionid');
      if (hasId) items.add(node);
    }

    final sessions = <EventSession>[];
    for (final e in items) {
      T? _get<T>(String name, T Function(String) cast) {
        final el = e.findElements('*').firstWhere(
          (el) => el.name.local.toLowerCase() == name.toLowerCase(),
          orElse: () => xml.XmlElement(xml.XmlName('')),
        );
        if (el.name.local.isEmpty) return null;
        final text = el.text.trim();
        if (text.isEmpty) return null;
        try {
          return cast(text);
        } catch (_) {
          return null;
        }
      }

      int? id = _get<int>('EventSessionId', (s) => int.parse(s));
      DateTime? sessionDate = _get<DateTime>('EventSessionDate', (s) => DateTime.parse(s));
      DateTime? endDateTime = _get<DateTime>('EndDateTime', (s) => DateTime.parse(s));
      int isAvailable = _get<int>('IsAvailable', (s) => int.parse(s)) ?? 0;
      int isNotAttended = _get<int>('IsNotAttended', (s) => int.parse(s)) ?? 0;
      int isBooked = _get<int>('IsBooked', (s) => int.parse(s)) ?? 0;
      int isCanceled = _get<int>('IsCanceled', (s) => int.parse(s)) ?? 0;
      int isClassSessionFull = _get<int>('IsClassSessionFull', (s) => int.parse(s)) ?? 0;

      if (id != null && sessionDate != null) {
        sessions.add(
          EventSession(
            eventSessionId: id,
            eventSessionDate: sessionDate,
            endDateTime: endDateTime,
            isAvailable: isAvailable == 1,
            isNotAttended: isNotAttended == 1,
            isBooked: isBooked == 1,
            isCanceled: isCanceled == 1,
            isClassSessionFull: isClassSessionFull == 1,
          ),
        );
      }
    }

    if (kDebugMode) {
      debugPrint('EventService.fetchSessions: parsed XML sessions=${sessions.length}');
    }

    return sessions;
  }
}

// Helpers for JSON parsing where values can be numbers or strings
int? _asInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is String && v.trim().isNotEmpty) return int.tryParse(v.trim());
  return null;
}

DateTime? _asDate(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  if (v is String && v.trim().isNotEmpty) {
    try {
      return DateTime.parse(v.trim());
    } catch (_) {
      return null;
    }
  }
  return null;
}
