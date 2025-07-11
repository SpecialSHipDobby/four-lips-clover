import 'package:flutter/foundation.dart';
import '../models/group/group_model.dart';
import '../models/group/group_detail_model.dart';
import '../models/group/member_model.dart';
import '../services/api/group_api.dart';
import 'package:flutter/widgets.dart';
import '../models/group/group_join_request_model.dart';
import '../services/invitation/deep_link_service.dart';

class GroupProvider with ChangeNotifier {
  final GroupApi _groupApi = GroupApi();

  // 사용자의 그룹 목록
  List<Group> _groups = [];

  // 현재 선택된 그룹
  Group? _selectedGroup;

  // 그룹 상세 정보 캐시
  final Map<int, GroupDetail> _groupDetailsCache = {};

  // 로딩 및 에러 상태
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Group> get groups => _groups;
  Group? get selectedGroup => _selectedGroup;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<int, GroupDetail> get groupDetailsCache => _groupDetailsCache;

  // 그룹 목록 설정 (API 호출 후)
  void setGroups(List<Group> groups) {
    _groups = groups;
    notifyListeners();
  }

  // 내 그룹 목록 조회 (API)
  Future<void> fetchMyGroups() async {
    _setLoading(true);
    try {
      final fetchedGroups = await _groupApi.getMyGroups();
      _groups = fetchedGroups;
      _error = null;
    } catch (e) {
      _error = '그룹 목록을 불러오는데 실패했습니다: $e';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    }
  }

  // 그룹 선택
  void selectGroup(int groupId) {
    try {
      _selectedGroup = _groups.firstWhere((group) => group.groupId == groupId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint(_error);
    }
  }

  // 그룹 상세 정보 조회 (API) - 캐싱 추가
  Future<GroupDetail?> fetchGroupDetail(int groupId) async {
    _setLoading(true);
    try {
      final groupDetail = await _groupApi.getGroupDetails(groupId);
      // 캐시에 저장
      _groupDetailsCache[groupId] = groupDetail;
      _error = null;
      return groupDetail;
    } catch (e) {
      _error = '그룹 상세 정보를 불러오는데 실패했습니다: $e';
      debugPrint(_error);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // 그룹장 닉네임 가져오기
  String? getOwnerNickname(int groupId) {
    // 해당 그룹의 정보 확인
    try {
      final group = _groups.firstWhere((g) => g.groupId == groupId);

      // 그룹장 ID (memberId)
      final ownerId = group.memberId;

      // 캐시된 상세 정보에서 그룹장 찾기
      if (_groupDetailsCache.containsKey(groupId)) {
        final members = _groupDetailsCache[groupId]!.members;
        try {
          final owner = members.firstWhere(
            (member) => member.memberId == ownerId,
          );
          return owner.nickname;
        } catch (e) {
          // 해당 멤버를 찾지 못한 경우
          return null;
        }
      }
    } catch (e) {
      // 해당 그룹을 찾지 못한 경우
      return null;
    }

    return null; // 정보가 없는 경우
  }

  // 그룹 멤버 수 가져오기
  int? getMemberCount(int groupId) {
    if (_groupDetailsCache.containsKey(groupId)) {
      return _groupDetailsCache[groupId]!.members.length;
    }
    return null;
  }

  // 새 그룹 추가 (API)
  Future<bool> addGroup({
    required String name,
    required String description,
    required bool isPublic,
    int? memberId, // 백엔드에서 현재 인증된 사용자 정보를 사용하므로 무시됨
  }) async {
    _setLoading(true);
    try {
      // 요청 데이터 로깅
      debugPrint(
        '요청 데이터: {name: $name, description: $description, isPublic: $isPublic}',
      );

      final newGroup = await _groupApi.createGroup(
        name: name,
        description: description,
        isPublic: isPublic,
      );

      _groups.add(newGroup);
      _selectedGroup = newGroup; // 새 그룹 자동 선택
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = '그룹 생성에 실패했습니다: $e';
      debugPrint(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 그룹 정보 업데이트 (API)
  Future<bool> updateGroup({
    required int groupId,
    required String name,
    required String description,
    required bool isPublic,
  }) async {
    _setLoading(true);
    try {
      final updatedGroup = await _groupApi.updateGroup(
        groupId: groupId,
        name: name,
        description: description,
        isPublic: isPublic,
      );

      // 기존 그룹 리스트에서 업데이트된 그룹 찾아 교체
      final index = _groups.indexWhere((group) => group.groupId == groupId);
      if (index != -1) {
        _groups[index] = updatedGroup;
      }

      // 선택된 그룹이 업데이트된 그룹이라면 선택된 그룹도 업데이트
      if (_selectedGroup?.groupId == groupId) {
        _selectedGroup = updatedGroup;
      }

      // 캐시된 상세 정보가 있다면 업데이트
      if (_groupDetailsCache.containsKey(groupId)) {
        final detail = _groupDetailsCache[groupId]!;
        _groupDetailsCache[groupId] = GroupDetail(
          groupId: updatedGroup.groupId,
          name: updatedGroup.name,
          description: updatedGroup.description,
          isPublic: updatedGroup.isPublic,
          members: detail.members,
        );
      }

      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = '그룹 수정에 실패했습니다: $e';
      debugPrint(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteGroup(int groupId) async {
    _setLoading(true);
    try {
      await _groupApi.deleteGroup(groupId);

      // 캐시된 그룹 목록에서 삭제
      _groups.removeWhere((group) => group.groupId == groupId);

      // 선택된 그룹이 삭제된 그룹이라면 선택 해제 또는 첫 번째 그룹 선택
      if (_selectedGroup?.groupId == groupId) {
        _selectedGroup = _groups.isNotEmpty ? _groups.first : null;
      }

      // 캐시에서도 제거
      _groupDetailsCache.remove(groupId);

      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = '그룹 삭제에 실패했습니다: $e';
      debugPrint(_error);
      notifyListeners(); // 에러 상태 알림
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 그룹 초대 링크 생성 (API)
  Future<String?> generateInviteLink(int groupId) async {
    _setLoading(true);
    try {
      final url = await _groupApi.createInvitationUrl(groupId);
      _error = null;
      return url;
    } catch (e) {
      _error = '초대 링크 생성에 실패했습니다: $e';
      debugPrint(_error);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // 초대 URL 생성 + 딥링크 변환
Future<String?> generateInviteLinkWithDeepLink(int groupId) async {
  _setLoading(true);
  try {
    final backendUrl = await _groupApi.createInvitationUrl(groupId);
    
    // 백엔드 URL을 앱 딥링크로 변환
    final deepLinkService = DeepLinkService();
    final deepLink = deepLinkService.convertToAppLink(backendUrl);
    
    _error = null;
    return deepLink;
  } catch (e) {
    _error = '초대 링크 생성에 실패했습니다: $e';
    debugPrint(_error);
    return null;
  } finally {
    _setLoading(false);
  }
}

  // 그룹 가입 요청 (API)
  Future<bool> joinGroup(String token) async {
    _setLoading(true);
    try {
      await _groupApi.joinGroupRequest(token);
      _error = null;
      return true;
    } catch (e) {
      _error = '그룹 가입 신청에 실패했습니다: $e';
      debugPrint(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 초대 링크 유효성 검사 (API)
  Future<Map<String, dynamic>?> checkInvitationLink(String token) async {
    _setLoading(true);
    try {
      final result = await _groupApi.checkInvitationStatus(token);
      _error = null;
      return result;
    } catch (e) {
      _error = '초대 링크 확인에 실패했습니다: $e';
      debugPrint(_error);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // 가입 요청 승인/거절 (API)
  // 기존 메서드 개선
  Future<bool> respondToJoinRequest({
    required int groupId,
    required String token,
    required int applicantId,
    required bool accept,
    String? adminComment,
  }) async {
    _setLoading(true);
    try {
      await _groupApi.approveOrRejectInvitation(
        groupId: groupId,
        token: token,
        accept: accept,
        applicantId: applicantId,
        adminComment: adminComment,
      );

      // 승인된 경우 그룹 상세 정보 새로고침
      if (accept) {
        // 그룹 상세 정보 새로고침
        final groupDetail = await fetchGroupDetail(groupId);

        // 가입 요청 목록도 새로고침 필요
        // 가입 요청 목록 새로고침 로직이 추가되어야 함
      }

      _error = null;
      return true;
    } catch (e) {
      _error = '가입 요청 처리에 실패했습니다: $e';
      debugPrint(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 가입 요청 목록 조회 메서드 추가
Future<List<GroupJoinRequest>?> fetchJoinRequestList(int groupId) async {
  _setLoading(true);
  try {
    final requests = await _groupApi.getJoinRequestList(groupId);
    _error = null;
    
    // 디버깅 로그 추가
    debugPrint('가입 요청 목록 조회 성공: ${requests.length}개 요청');
    for (var req in requests) {
      debugPrint('요청 ID: ${req.id}, 멤버: ${req.member.nickname}, 상태: ${req.status}');
    }
    
    return requests;
  } catch (e) {
    _error = '가입 요청 목록 조회에 실패했습니다: $e';
    debugPrint(_error);
    return null;
  } finally {
    _setLoading(false);
  }
}

  void _setLoading(bool loading) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isLoading != loading) {
        _isLoading = loading;
        notifyListeners();
      }
    });
  }

  // 에러 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // 캐시된 그룹 상세 정보 가져오기
  GroupDetail? getGroupDetail(int groupId) {
    if (_groupDetailsCache.containsKey(groupId)) {
      return _groupDetailsCache[groupId];
    }
    return null;
  }

  // 이미 그룹에 속한 사용자만 접근할 수 있는 API를 사용하면 권한 문제가 발생할 수 있으므로
// 초대 링크에서 얻은 정보를 기반으로 기본적인 그룹 정보 객체를 생성
Future<GroupDetail?> createBasicGroupInfo(int groupId) async {
  try {
    // 기본적인 GroupDetail 객체 생성
    final basicInfo = GroupDetail(
      groupId: groupId,
      name: '초대된 그룹',
      description: '그룹에 참여하시겠습니까?',
      isPublic: true,
      members: [
        Member(
          memberId: 0,
          email: 'unknown@example.com',
          nickname: '그룹 관리자',
          role: 'OWNER'
        )
      ],
    );
    return basicInfo;
  } catch (e) {
    debugPrint('기본 그룹 정보 생성 오류: $e');
    return null;
  }
}
}
