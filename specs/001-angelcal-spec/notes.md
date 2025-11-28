# 구현 상태 메모 (문서화)

- 템플릿: SwiftData 기반 TemplateEntity/TemplateRepository 추가, TemplateClient live 연결. 템플릿 리스트/편집/적용 플로우를 FeatureTemplate 모듈로 구성하고 설정 화면에서 접근 가능.
- 이벤트: 생성 폼 기본값/검증 보강, 복사/삭제/템플릿 저장 액션 EventDetail에 추가, 캘린더 목록에서 이벤트 새로고침 연동.
- 검색: 로컬 인덱스 기반 검색 개선(LOWER 텍스트 필터), 정렬 옵션 및 상세 시트 추가.
- 설정/위젯: Notification/Appearance/Calendar/Widget/Account 설정 화면 초안 완료, 위젯 config SwiftData 엔티티 추가. 위젯 가이드 모듈 placeholder 추가.
- 성능: `Docs/performance-notes.md`에 1000건 이벤트 기준 프로파일링 체크리스트 초안 작성.
