# Tasks: AngelCal iOS 프로젝트

**Input**: Design documents from `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/specs/001-angelcal-spec/`
**Prerequisites**: plan.md (required), spec.md (required for user stories)

**Tests**: 스펙에서 별도 테스트 선행 요구가 없으므로 테스트 태스크는 포함하지 않는다. 각 스토리의 독립 검증 기준만 기재.

**Organization**: 사용자 스토리별로 작업을 묶어 독립 구현·검증 가능하게 구성한다. 각 스토리의 독립 검증 기준만 기재.

## Phase 1: Setup (Shared Infrastructure)
**Purpose**: 프로젝트 초기화 및 현 코드 재사용 원칙을 반영한 기본 환경 준비

- [X] T001 기존 모듈·코드 인벤토리 작성(재사용 후보 표시) `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Docs/inventory.md`
- [X] T002 Tuist 설정 점검 및 `Project.swift` 갱신(현 모듈 유지, 새 모듈 최소 추가) `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Project.swift`
- [X] T003 [P] SwiftLint·SwiftFormat 설정 배치 `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Configs/linters/.swiftlint.yml`
- [X] T004 [P] DSKit 기본 토큰 파일 생성 또는 보강 `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/DSKit/Sources/Tokens.swift`

---

## Phase 2: Foundational (Blocking Prerequisites)
**Purpose**: 모든 스토리의 공통 기반 확보; 기존 코드 재사용을 우선하고 불필요한 추상화 추가 금지

- [X] T005 Core 모듈에 도메인 모델 스텁 보강(User/Calendar/Event 등) `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/Core/Sources/DomainModels.swift`
- [X] T006 Core 모듈에 Repository 프로토콜 초안 정의(Event/Calendar/Settings) `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/Core/Sources/Repositories.swift`
- [X] T007 SupabaseClient 모듈 세션/요청 래퍼 기본 구현(기존 코드 있으면 보강) `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/SupabaseClient/Sources/SupabaseClient.swift`
- [X] T008 SwiftDataClient 컨테이너 초기화와 fetch/save 헬퍼 추가 `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/SwiftDataClient/Sources/SwiftDataStack.swift`
- [X] T009 Data 모듈에 OutboxEntity 및 OutboxService 스켈레톤 작성(삭제 대신 감싸기) `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/Data/Sources/Outbox.swift`
- [X] T010 DesignSystem 공통 컴포넌트 베이스(ViewModifiers, Buttons) 생성 또는 기존 재정리 `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/DesignSystem/Sources/Components.swift`
- [X] T011 App 루트에 AppFeature Store 세팅 및 탭 컨테이너 배선(기존 뷰 재사용) `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/App/Sources/AppFeature.swift`
- [X] T037 초기 동기화 pullAll 및 pullRange 트리거 배선(AppFeature onAppear, 설정 강제 동기화 포함) `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/Core/Sources/SyncClient.swift`
- [X] T038 네트워크 변화/백그라운드 task 기반 Outbox Push & Pull 실행 로직 구현 `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/Data/Sources/SyncService.swift`
- [X] T039 LWW 충돌 처리(updated_at 비교) 및 remoteId 매핑 보강 `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/Data/Sources/Repositories.swift`
- [X] T040 동기화 실패 백오프/재시도·lastError 기록 및 설정 화면 노출용 상태 훅 추가 `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/Data/Sources/Outbox.swift`
- [X] T041 초기 진입 전 최소 데이터 확보(캘린더/이벤트/설정 preload) 보장 `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/App/Sources/AppFeature.swift`

**Checkpoint**: Foundational 완료 후 스토리 작업 병행 가능

---

## Phase 3: User Story 0 - 온보딩/로그인 (Priority: P1)
**Goal**: 스플래시→온보딩→로그인/게스트 분기 후 기본 데이터 시드, 3분 내 메인 진입
**Independent Test**: 첫 실행에서 온보딩 슬라이드 완료 후 Apple 로그인 또는 게스트 진입 시 3분 내 메인 탭, 세션 복원 시 바로 메인 진입

### Implementation for User Story 0
- [X] T042 [US0] AppFeature에 auth/온보딩 상태 및 라우팅 로직 추가 `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/App/Sources/AppFeature.swift`
- [X] T043 [US0] 온보딩 슬라이드 뷰 구현(SCR-02) 및 완료 플래그 저장 `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/Features/FeatureMain/Sources/OnboardingView.swift`
- [X] T044 [US0] Sign in with Apple + Supabase Auth 연동, 세션 재개 처리 `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/Core/Sources/Clients.swift`
- [X] T045 [US0] 로그인 직후 기본 캘린더/설정 시드 및 프로필 fetch `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/Data/Sources/SeedService.swift`
- [X] T046 [US0] 게스트 모드 시작 및 로그인 시 로컬 데이터 마이그레이션(Outbox 업로드) `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/Data/Sources/MigrationService.swift`

**Checkpoint**: 온보딩/로그인 경로가 동작하고 기본 데이터가 준비된 상태로 메인 진입

---

## Phase 4: User Story 1 - 오늘/이번 주 한눈 파악 (Priority: P1) 🎯 MVP
**Goal**: 월/주 뷰와 일자 리스트에서 오늘·이번 주 맥락을 최소 탭으로 확인
**Independent Test**: 온보딩 후 3탭 이내 오늘/이번 주 확인, 월↔주 전환 시 선택 날짜 유지, 리스트가 선택 날짜와 동기화

### Implementation for User Story 1
- [X] T012 [US1] MainFeature에 `selectedDate`, `viewMode` 상태·액션 정의(기존 상태 재사용 가능 여부 확인) `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/Features/FeatureMain/Sources/MainFeature.swift`
- [X] T013 [US1] CalendarFeature 월/주 전환 뷰 구현 및 스와이프 제스처 연결(가능하면 기존 컴포넌트 재활용) `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/Features/FeatureCalendar/Sources/CalendarFeatureView.swift`
- [X] T014 [P] [US1] CalendarFeature Reducer에 날짜 선택→DayListFeature 연동 로직 추가 `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/Features/FeatureCalendar/Sources/CalendarFeature.swift`
- [X] T015 [P] [US1] DayListFeature에서 선택 날짜/기간 이벤트 로컬 fetch 구현(기존 쿼리 헬퍼 사용) `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/Features/FeatureCalendar/Sources/DayListFeature.swift`
- [X] T016 [US1] 캘린더 당겨서 새로고침→SyncClient.pullRange(month span) 트리거 배선 `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/Core/Sources/SyncClient.swift`
- [X] T017 [US1] 오늘 날짜 하이라이트 및 색상 토큰 적용(DesignSystem) `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/DSKit/Sources/CalendarStyles.swift`

**Checkpoint**: 월/주 전환 및 일자 리스트가 동작하고 오늘/이번 주 파악 가능

---

## Phase 5: User Story 2 - 빠른 일정 생성 (Priority: P1)
**Goal**: 메인 캘린더에서 3탭 이내 새 이벤트 생성·반영 (온라인/오프라인 동일)
**Independent Test**: 오프라인에서 생성 후 즉시 달력·리스트 반영, 재연결 시 중복 없이 서버 동기화

### Implementation for User Story 2
- [X] T018 [US2] EventEditFeature Form 상태/검증 로직 초안 작성(제목/시간/올데이) `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/Features/FeatureEventEdit/Sources/EventEditFeature.swift`
- [X] T019 [P] [US2] 기본값 주입 로직(기본 캘린더·알림·기간) 구현 또는 기존 설정 로직 재사용 `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/Features/FeatureEventEdit/Sources/EventEditDefaults.swift`
- [X] T020 [US2] EventClient.create: SwiftData 저장 → Outbox enqueue → UI 낙관적 업데이트 `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/Data/Sources/Repositories.swift`
- [X] T021 [P] [US2] CalendarFeature에서 FAB/롱탭 → EventEdit 시트 프레젠트 연결 `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/Features/FeatureCalendar/Sources/CalendarFeature.swift`
- [X] T022 [US2] 생성 후 리스트/달력 즉시 반영(로컬 fetch 갱신) 및 알림 스케줄 트리거 `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/Features/FeatureCalendar/Sources/CalendarFeatureReducer.swift`

**Checkpoint**: 오프라인 포함 빠른 일정 생성 흐름 완성

---

## Phase 6: User Story 3 - 일정 수정/이동 (Priority: P2)
**Goal**: 이벤트 시간 변경·복사·삭제를 상세 시트에서 처리, 알림/동기화 일관성 유지
**Independent Test**: 시간 변경 시 달력/리스트/알림 모두 즉시 갱신, 복사 시 원본 유지·신규 생성 확인

### Implementation for User Story 3
- [X] T023 [US3] EventDetailFeature에서 편집/복사/삭제 액션 정의 및 라우팅 `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/Features/FeatureEventDetail/Sources/EventDetailFeature.swift`
- [X] T024 [P] [US3] EventClient.update: SwiftData 수정 → Outbox enqueue → updated_at 반영 `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/Data/Sources/Repositories.swift`
- [X] T025 [P] [US3] EventClient.copy: 기존 이벤트를 다른 날짜로 복사하는 유틸 구현 `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/Data/Sources/Repositories.swift`
- [X] T026 [US3] 삭제 시 soft delete(`deletedAt`) 처리 및 UI 필터 연동 `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/Data/Sources/Repositories.swift`
- [X] T027 [US3] 알림 재스케줄(수정/삭제 시 취소·재등록) `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/Core/Sources/Clients.swift`

**Checkpoint**: 수정·복사·삭제가 데이터/알림/뷰 일관성 있게 동작

---

## Phase 7: User Story 4 - 검색과 필터로 과거 일정 탐색 (Priority: P3)
**Goal**: 키워드+기간+캘린더 필터로 과거 이벤트 검색, 2초 내 결과 반환
**Independent Test**: 제목/메모/위치로 검색 시 2초 이내 결과, 필터 토글 시 즉시 리스트 반응, 결과에서 상세 이동

### Implementation for User Story 4
- [X] T028 [US4] SearchFeature State에 query/dateRange/calendarFilter/results 정의 `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/Features/FeatureSearch/Sources/SearchFeature.swift`
- [X] T029 [P] [US4] 로컬 인덱스 기반 검색 쿼리(LOWER(title+memo+location+url)) 구현 `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/Data/Sources/SearchRepository.swift`
- [X] T030 [P] [US4] Search 결과 리스트 뷰와 정렬 옵션(UI) 추가 `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/Features/FeatureSearch/Sources/SearchView.swift`
- [X] T031 [US4] 검색 결과에서 EventDetail로 딥링크 라우팅 `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/Features/FeatureSearch/Sources/SearchNavigation.swift`
- [X] T032 [US4] 필요 시 최근 범위 Pull 트리거(옵션) 연결 `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/Core/Sources/SyncClient.swift`

**Checkpoint**: 검색·필터가 성능 목표 내 동작하고 상세로 이동 가능

---

## Phase 8: User Story 5 - 설정/위젯/알림 (Priority: P2)
**Goal**: 설정 화면에서 캘린더/외관/알림/계정 제어, 위젯 구성·딥링크·배지/데일리 요약 동작
**Independent Test**: 설정 변경 시 메인/위젯에 즉시 반영, 알림/배지/데일리 요약 설정대로 동작, 위젯 탭 딥링크 정상 진입

### Implementation for User Story 5
- [X] T048 [US5] SettingsRootFeature 라우팅/상태 구성 및 섹션 배치 `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/Features/FeatureSettings/Sources/SettingsRootFeature.swift`
- [X] T049 [US5] CalendarSettingsFeature: 색상/기본/표시/삭제/숨김 제어 `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/Features/FeatureSettings/Sources/CalendarSettingsFeature.swift`
- [X] T050 [US5] AppearanceSettingsFeature: 테마/폰트/텍스트 크기/주 시작 요일/공휴일 표시 반영 `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/Features/FeatureSettings/Sources/AppearanceSettingsFeature.swift`
- [X] T051 [US5] NotificationSettingsFeature: 기본 알림 시점·올데이 알림·데일리 요약·배지 타입 설정 및 UNNotification 재스케줄 `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/Features/FeatureSettings/Sources/NotificationSettingsFeature.swift`
- [X] T052 [US5] WidgetConfig 관리 및 WidgetKit 타임라인/딥링크 반영 `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/Features/FeatureSettings/Sources/WidgetGuideFeature.swift`
- [X] T053 [US5] AccountSettings: 로그아웃, 데이터 초기화(로컬 DB reset+Outbox purge), 약관/버전 노출 `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/Features/FeatureSettings/Sources/AccountSettingsFeature.swift`

**Checkpoint**: 설정/위젯/알림 기능이 요구대로 반영되고 딥링크·배지·데일리 요약이 동작

---

## Phase 8B: Template 관리 (SCR-08, Priority: P2)
**Goal**: 템플릿 목록/추가/수정/삭제/정렬을 통해 반복 일정 생성 속도 향상
**Independent Test**: 템플릿에서 이벤트를 2탭 내 생성 가능, 템플릿 수정·삭제 시 리스트와 생성 기본값에 즉시 반영

### Implementation for Templates
- [X] T054 [US6] TemplateListFeature 목록/정렬 뷰 구현 `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/Features/FeatureTemplate/Sources/TemplateListFeature.swift`
- [X] T055 [US6] 템플릿 추가/수정 폼 및 검증 `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/Features/FeatureTemplate/Sources/TemplateEditFeature.swift`
- [X] T056 [US6] 템플릿 삭제/정렬 액션 및 UI 반영 `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/Features/FeatureTemplate/Sources/TemplateListFeature.swift`
- [X] T057 [US6] 이벤트 → 템플릿 저장 플로우 추가 `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/Features/FeatureEventDetail/Sources/EventDetailFeature.swift`
- [X] T058 [US6] 템플릿 기본값을 EventEditFeature에 적용 `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/Features/FeatureEventEdit/Sources/EventEditFeature.swift`

**Checkpoint**: 템플릿 CRUD 및 이벤트 생성 연동이 동작

---

## Phase 9: Polish & Cross-Cutting Concerns
**Purpose**: 전 스토리 품질 보강, 성능/UX 개선, 과도한 변경 없이 기존 자산 최적 활용

- [X] T033 [P] 성능 프로파일링(월간/주간 1000건 이벤트 시 60fps 확인) `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Docs/performance-notes.md`
- [X] T034 오류/동기화 상태 노출 UX 다듬기(설정 배지, 재시도 버튼) `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/FeatureSettings/Sources/SettingsRootFeature.swift`
- [X] T035 위젯 타임라인/딥링크 정합성 점검 및 개선 `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/FeatureSettingsWidgetGuide/Sources/WidgetGuideFeature.swift`
- [X] T036 문서화: plan.md 대비 구현 상태 업데이트(리팩터링 결정 포함) `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/specs/001-angelcal-spec/notes.md`

---

## Dependencies & Execution Order
- Phase 1 → Phase 2 → User Stories(Phases 3–6) 순으로 진행. Foundational 완료 후 스토리는 우선순위(P1→P2→P3) 기준이지만 병렬 가능.
- User Story 간 직접 데이터 의존 없음; 공통 인프라만 공유.
- Polish(Phase 7)는 모든 스토리 완료 후 수행.

### User Story Completion Order (graph)
US0 (P1) → US1 (P1) → US2 (P1) → US3 (P2) → US5 (P2) → US6 (P2) → US4 (P3)

### Parallel Opportunities
- [P] 태스크: T003, T004, T014, T015, T019, T021, T024, T025, T029, T030, T033.
- Foundational 이후 각 스토리는 다른 담당자가 병렬 착수 가능.

### MVP Scope
- US1 완료 시점이 MVP. 이후 US2~US5~US6~US4 순으로 가치 확장.

### Independent Test Criteria (per story)
- US0: 첫 실행→온보딩→Apple 로그인/게스트 선택 후 3분 내 메인 탭 도달, 세션 복원 시 바로 메인 진입.
- US1: 3탭 이내 오늘/이번 주 확인, 월↔주 전환 시 선택 날짜 유지, 리스트가 선택 날짜와 동기화.
- US2: 오프라인 이벤트 생성 후 즉시 표시, 재연결 시 중복 없이 서버 반영.
- US3: 시간 변경·복사 후 달력/리스트/알림 동시 갱신, soft delete 후 뷰에서 제외.
- US4: 키워드+필터 검색 2초 내 결과, 필터 토글 즉시 반응, 결과에서 상세로 이동.
- US5: 설정 변경 시 메인 화면/위젯/알림이 앱 재시작 없이 즉시 반영.
- US6: 템플릿으로 2탭 내 이벤트 생성, 템플릿 수정·삭제 시 목록과 기본값에 즉시 반영.

### Format Validation
- 모든 태스크가 `- [ ] T### [P?] [US?] 설명 (파일 경로)` 형식을 준수한다.

- [X] T060 [US5] 위젯 타입/캘린더/올데이/최대 이벤트 설정 UI 및 타임라인 반영 검증 `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/Features/FeatureSettings/Sources/WidgetGuideFeature.swift`
- [X] T061 [US5] 위젯 딥링크/새로고침 실패 시 백오프 및 마지막 성공 상태 유지 처리 `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/FeatureSettingsWidgetGuide/Sources/WidgetGuideFeature.swift`
- [X] T062 [US0-US5] 오류/재시도 UX 통합: 이벤트 CRUD·Sync·알림/위젯 경로 재시도/취소/롤백 메시지 처리 `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/Core/Sources/Clients.swift`
- [X] T063 [P] [NFR] SC-001~SC-006 계측 포인트 추가(App launch, 온보딩 완료 시간, 이벤트 CRUD 성공률, 검색 응답 시간, 알림/위젯 진입 성공률) `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/App/Sources/AppFeature.swift`
- [X] T064 [US5] 위젯 타임라인 생성 시 SwiftData 캐시 + SyncClient.pullRange 병행, 실패 로그/재시도 훅 추가 `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/Features/FeatureSettings/Sources/WidgetGuideFeature.swift`
- [X] T065 [US5] WidgetGuide 문서/가이드 컨텐츠 확장(타입 소개, 배치 방법, 새로고침 주기, 딥링크 예시) `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/FeatureSettingsWidgetGuide/Sources/WidgetGuideFeature.swift`
- [X] T066 [P] [NFR] 공휴일/음력 데이터 소스 번들링 및 범위 명시(한국 기준) `/Volumes/jaehoon_ex/jaehoon_ex/Desktop/AngelCal/Projects/Data/Sources/Mappers.swift`
