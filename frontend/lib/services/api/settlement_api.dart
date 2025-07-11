// lib/services/api/settlement_api.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/settlement/settlement_model.dart';
import '../../models/settlement/settlement_request_model.dart';
import '../../models/settlement/settlement_situation_model.dart';
import '../../models/settlement/update_participant_model.dart';
import 'api_util.dart';

class SettlementApi {
  // .env 파일에서 API 기본 URL을 가져옵니다.
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? '';
  static const String planApiPrefix = '/api/plans';
  static const String expenseApiPrefix = '/api/expenses';

  // 인증 토큰 가져오기 (ApiUtil 사용)
  Future<String?> _getAuthToken() async {
    return await ApiUtil.getJwtToken();
  }

  // 토큰 유효성 검사 (ApiUtil 사용)
  bool _validateToken(String? token) {
    return ApiUtil.validateToken(token);
  }

  /// 정산 생성하기
  /// [planId] 계획 ID
  Future<void> createSettlement(int planId) async {
    final token = await _getAuthToken();

    if (!_validateToken(token)) {
      throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
    }

    final url = Uri.parse('$baseUrl$planApiPrefix/$planId/settlement');

    debugPrint('정산 생성 API 호출: $url');

    try {
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      debugPrint('응답 코드: ${response.statusCode}');

      if (response.statusCode != 201) {
        throw Exception(
          '정산 생성에 실패했습니다: ${response.statusCode}, ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('API 호출 중 에러 발생: $e');
      rethrow;
    }
  }

  /// 정산 상세 정보 조회하기
  /// [planId] 계획 ID
  Future<Settlement> getSettlementDetail(int planId) async {
    final token = await _getAuthToken();

    if (!_validateToken(token)) {
      throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
    }

    final url = Uri.parse('$baseUrl$planApiPrefix/$planId/settlement');

    debugPrint('정산 상세 조회 API 호출: $url');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      debugPrint('응답 코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        return Settlement.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        throw Exception(
          '정산 정보 조회에 실패했습니다: ${response.statusCode}, ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('API 호출 중 에러 발생: $e');
      rethrow;
    }
  }

  /// 정산 요청하기
  /// [planId] 계획 ID
  Future<SettlementRequest> requestSettlement(int planId) async {
    final token = await _getAuthToken();

    if (!_validateToken(token)) {
      throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
    }

    final url = Uri.parse('$baseUrl$planApiPrefix/$planId/settlement/request');

    debugPrint('정산 요청 API 호출: $url');

    try {
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      debugPrint('응답 코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        return SettlementRequest.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)),
        );
      } else {
        throw Exception(
          '정산 요청에 실패했습니다: ${response.statusCode}, ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('API 호출 중 에러 발생: $e');
      rethrow;
    }
  }

  /// 정산 참여자 업데이트하기
  /// [expenseId] 비용 ID
  /// [memberIds] 참여자 ID 목록
  Future<UpdateParticipantResponse> updateParticipants(
    int expenseId,
    List<int> memberIds,
  ) async {
    final token = await _getAuthToken();

    if (!_validateToken(token)) {
      throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
    }

    final url = Uri.parse('$baseUrl$expenseApiPrefix/$expenseId/participants');

    debugPrint('정산 참여자 업데이트 API 호출: $url');

    final request = UpdateParticipantRequest(memberId: memberIds);

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );

      debugPrint('응답 코드: ${response.statusCode}');
      debugPrint('응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        return UpdateParticipantResponse.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)),
        );
      } else {
        throw Exception(
          '정산 참여자 업데이트에 실패했습니다: ${response.statusCode}, ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('API 호출 중 에러 발생: $e');
      rethrow;
    }
  }
  // lib/services/api/settlement_api.dart에 추가할 코드

  /// 정산 현황 조회하기
  /// [planId] 계획 ID
  Future<List<SettlementSituationResponse>> getSettlementSituation(
    int planId,
  ) async {
    final token = await _getAuthToken();

    if (!_validateToken(token)) {
      throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
    }

    final url = Uri.parse(
      '$baseUrl$planApiPrefix/$planId/settlement/situation',
    );

    debugPrint('정산 현황 조회 API 호출: $url');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      debugPrint('응답 코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        final dynamic decodedData = jsonDecode(utf8.decode(response.bodyBytes));

        // 응답 타입 로깅
        debugPrint('응답 데이터 타입: ${decodedData.runtimeType}');

        // 단일 객체인 경우 (Map)
        if (decodedData is Map<String, dynamic>) {
          debugPrint('응답이 단일 객체입니다. 리스트로 변환합니다.');
          return [SettlementSituationResponse.fromJson(decodedData)];
        }
        // 이미 리스트인 경우
        else if (decodedData is List) {
          debugPrint('응답이 리스트입니다. 객체를 변환합니다.');
          return decodedData
              .map((json) => SettlementSituationResponse.fromJson(json))
              .toList();
        }
        // 예상치 못한 타입인 경우
        else {
          throw FormatException('예상치 못한 응답 형식: ${decodedData.runtimeType}');
        }
      } else {
        throw Exception(
          '정산 현황 조회에 실패했습니다: ${response.statusCode}, ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('API 호출 중 에러 발생: $e');
      rethrow;
    }
  }

  /// 정산 거래 완료 처리하기
  /// [planId] 계획 ID
  /// [transactionId] 거래 ID
  Future<String> completeTransaction(int planId, int transactionId) async {
    final token = await _getAuthToken();

    if (!_validateToken(token)) {
      throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
    }

    final url = Uri.parse(
      '$baseUrl$planApiPrefix/$planId/settlement/transactions/$transactionId/complete',
    );

    debugPrint('정산 거래 완료 API 호출: $url');

    try {
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      debugPrint('응답 코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception(
          '정산 거래 완료 처리에 실패했습니다: ${response.statusCode}, ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('API 호출 중 에러 발생: $e');
      rethrow;
    }
  }
}
