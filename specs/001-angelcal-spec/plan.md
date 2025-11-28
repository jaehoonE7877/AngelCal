# Implementation Plan: AngelCal iOS (Project Level)

**Branch**: `001-angelcal-spec`  
**Status**: Draft  
**Scope**: spec.md에 정의된 AngelCal MVP 범위 내에서 구현 전략, 모듈 구조, 데이터/동기화, 네비게이션, 테스트, 단계별 마일스톤을 정리한다.

## 1. 아키텍처 원칙
- 100% SwiftUI, UIKit 금지. iOS 18+, Swift 6+. 
- TCA 중심 Feature 설계: State/Action/Reducer/Effect 단위, 의존성 주입으로 Testable하게 구성.
- 멀티 모듈(Tuist) + 일방향 의존성: Feature → Core → Data → (SupabaseClient | SwiftDataClient) → Shared. Feature 모듈 간 직접 의존 금지.
- 로컬 우선(Local-first): SwiftData 캐시가 즉시 UI를 구동, Supabase는 단일 진실 소스. Outbox 패턴으로 비동기 Push.
- Design System 일원화: DSKitTokens(토큰), DesignSystem(컴포넌트)로 UI 일관성 확보.
- Unit Test: Swift Testing Framework (import Testing), XCTest 사용 금지
- 기존 코드 재사용 우선: 가능하면 기존 구현을 감싸는 어댑터/리듀서 재배선으로 시작하고, 대체가 필요할 때만 신규 모듈/타입을 추가한다. 삭제·대규모 재작성은 MVP 이후로 미룬다.
- 오버엔지니어링 금지: 현재 스펙에 필요 없는 범용화/추상화(예: 다중 백엔드 스위치, 과도한 DI 계층, 불필요한 서브모듈 분리)를 추가하지 않는다. 성능·테스트 이득이 없는 리팩터는 보류한다.
- 점진 리팩터링 원칙: 기존 파일을 그대로 두고 작은 단위로 분리(추출→대체→정리)하며, 각 단계 후 빌드/테스트 가능 상태를 유지한다.

## 2. Tuist 모듈 구조
| 모듈 | 책임/역할 | Public API(개념) | 의존 모듈 |
|------|-----------|------------------|-----------|
| App | 앱 엔트리, 환경 설정, 루트 Store 구성, 딥링크 처리 | `AppFeature` reducer, 앱 라이프사이클 훅 | FeatureMain, Shared |
| FeatureMain | 탭 루트(Tabs) 관리, 공통 상태(선택 날짜, 사용자 설정) 조율 | `MainFeature.State/Action/Reducer` | FeatureCalendar, FeatureSearch, FeatureSettings, Core, DesignSystem |
| FeatureCalendar | 캘린더 탭 루트, 월/주/리스트 뷰, 이벤트 생성/상세 진입 | `CalendarFeature.*`, 하위 Feature 라우팅 | Core, DesignSystem |
| FeatureSearch | 검색 탭, 필터 상태, 검색 결과 목록 | `SearchFeature.*` | Core, DesignSystem |
| FeatureSettings | 설정 탭 루트, 각 설정 Feature 컨테이너 | `SettingsRootFeature.*` | FeatureSettingsSubmodules, Core, DesignSystem |
| FeatureSettingsCalendar | 캘린더 관리 UI | `CalendarSettingsFeature` | Core, DesignSystem |
| FeatureSettingsAppearance | 외관/테마 | `AppearanceSettingsFeature` | Core, DesignSystem |
| FeatureSettingsNotification | 알림/배지 | `NotificationSettingsFeature` | Core, DesignSystem |
| FeatureSettingsAccount | 계정/데이터 | `AccountSettingsFeature` | Core, DesignSystem |
| FeatureSettingsWidgetGuide | 위젯 가이드 | `WidgetGuideFeature` | Core, DesignSystem |
| FeatureEventDetail | 이벤트 상세 시트 | `EventDetailFeature` | Core, DesignSystem |
| FeatureEventEdit | 이벤트 생성/편집 폼 | `EventEditFeature` | Core, DesignSystem |
| FeatureTemplate | 템플릿 목록/편집 | `TemplateListFeature` | Core, DesignSystem |
| Core | 도메인 모델, UseCase/Client 프로토콜(TCA Dependencies), 공통 유틸 | `EventClient`, `CalendarClient`, `SettingsClient`, `AuthClient`, `SyncClient`, 모델 타입 | Shared |
| Data | Repository 구현, 매핑 로직, Outbox/Sync 서비스 | `EventRepository`, `CalendarRepository`, `SettingsRepository`, `SyncService`, 매퍼 | SupabaseClient, SwiftDataClient, Shared |
| SupabaseClient | Supabase PostgREST/RPC 래퍼, 인증 연동 | `SupabaseSession`, `SupabaseAPI` | Shared |
| SwiftDataClient | SwiftData Stack, 컨텍스트/쿼리 헬퍼 | `SwiftDataStack`, fetch/save 유틸 | Shared |
| DesignSystem | 공통 SwiftUI 컴포넌트, 스타일 | 버튼/리스트/폼, 색상/타이포 적용 컴포넌트 | DSKitTokens, Shared |
| DSKitTokens | 색상/타이포/spacing 토큰 정의 | Token structs | Shared |
| Shared | 공통 타입(Extensions, Logging, Result, UUID/Date helpers) | Helpers, Logger | (최하위) |

의존성 규칙: Feature 모듈은 서로 직접 참조 금지. Data는 Core에 역의존하지 않음(인터페이스는 Core에, 구현은 Data에 존재).

## 3. 데이터 & 퍼시스턴스 설계
### 3.1 엔티티 매핑 개요 (Supabase ↔ SwiftData)
| Supabase 테이블 | SwiftData 엔티티 | 핵심 필드(요약) | 비고 |
|-----------------|-------------------|-----------------|------|
| user_profiles | ProfileEntity | remoteId(uuid), locale, language, createdAt, updatedAt | 로그인 사용자 1:1 |
| calendars | CalendarEntity | remoteId, name, colorHex, isPrimary, isHidden, deletedAt, updatedAt | user_id FK |
| events | EventEntity | remoteId, calendarLocalId, title, startAt, endAt, isAllDay, location, notes, url, recurrenceRule, colorOverride, deletedAt, updatedAt | calendar_id FK |
| event_reminders | EventReminderEntity | remoteId, eventLocalId, offsetMinutes, channel, deletedAt, updatedAt | Event 1:N |
| event_templates | EventTemplateEntity | remoteId, title, defaultDuration, defaultReminderOffset, location, notes, color, deletedAt, updatedAt | |
| notification_settings | NotificationSettingEntity | remoteId, defaultReminderOffset, allDayReminderTime, dailySummaryTime, badgeType, sound, updatedAt | 단일 레코드 |
| appearance_settings | AppearanceSettingEntity | remoteId, weekStart, theme, fontScale, showHolidays, showWeekNumber, timeFormat, lunar, languageOverride, updatedAt | 단일 레코드 |
| widget_configs | WidgetConfigEntity | remoteId, widgetType, calendarIds, maxEvents, includeAllDay, updatedAt | 여러 레코드 |
| outbox (로컬 전용) | OutboxEntity | id(local), entityType, entityLocalId, operation(c/u/d), payload(json), createdAt, retryCount, lastError | SwiftData only |

### 3.2 로컬 스키마 고려 사항
- 모든 엔티티에 `remoteId`(옵션), `updatedAt`, `deletedAt` 포함. `remoteId`가 nil이면 신규/미동기화 상태.
- `user_id`는 현재 사용자 기준 단일 세션이므로 로컬 DB에는 명시 필드 생략 가능(컨테이너 분리로 격리)하되, 동기화 payload에는 포함.
- 인덱스: `startAt`/`endAt` 범위, `calendarLocalId`, `updatedAt`, `deletedAt`에 인덱스 생성. 검색용 텍스트 필드는 간단한 로컬 인덱스(LOWER(title+notes+location)) 컬럼 추가 고려.
- Event ↔ Reminder: SwiftData에서 `@Relationship(.cascade)`로 1:N 유지, 알림 스케줄 시 Reminder 레코드 기반으로 UNNotificationRequest 생성.
- Soft delete: `deletedAt` 존재 시 UI 필터에서 제외, Push 시 삭제 이벤트 전송, Pull 시 로컬에서도 삭제 표시 후 정리.

### 3.3 알림 연동
- `EventReminderEntity.offsetMinutes`를 기준으로 로컬 알림 스케줄링. 저장/수정 시 스케줄 갱신, 삭제 시 취소.
- Daily Summary: `NotificationSettingEntity.dailySummaryTime` 기반 백그라운드 스케줄.

## 4. 동기화 & 오프라인 구현 계획
### 4.1 OutboxEntity 설계
- 필드: `id(UUID)`, `entityType(enum)`, `entityLocalId`, `operation(create/update/delete)`, `payload(json blob)`, `createdAt`, `retryCount`, `lastError`, `priority(optional)`.
- SwiftData fetch 시 `retryCount`/`createdAt`로 정렬, 네트워크 가능 상태에서 배치 전송.

### 4.2 Pull / Push 트리거
- 앱 런칭: AppFeature init 시 `SyncClient.pullAll()` (SPL 002).
- 메인 캘린더 당겨서 새로고침: `CalendarFeature` → `SyncClient.pullRange(month span)`.
- 설정 화면 강제 동기화: `SettingsRootFeature` → `SyncClient.pullAll(force:true)`.
- CRUD 발생: Repository가 저장 후 Outbox 레코드 생성, UI는 즉시 로컬 데이터 반영.
- 네트워크 변화/백그라운드 refresh task: `SyncService`가 Outbox dequeue 후 Push, Pull 수행.

### 4.3 엔티티별 플로우 (요약)
- Create: Repository가 SwiftData에 저장 → Outbox(op=create, payload=로컬 스냅샷) → Push 성공 시 `remoteId`/`updatedAt` 갱신, Outbox 제거.
- Update: 변경분 저장 → Outbox(op=update, diff 또는 전체 payload) → 서버 `updated_at` 반환으로 로컬 갱신.
- Delete: `deletedAt` 세팅 후 저장 → Outbox(op=delete) → 서버 반영 후 로컬 정리. 영구 삭제는 배치 클린업에서 수행.
- Settings류(단일 레코드)는 create 대신 upsert 흐름으로 처리.

### 4.4 오류/재시도 관리
- `retryCount` 기반 지수 백오프(예: 1s, 5s, 30s, 5m, 30m). 임계 초과 시 Outbox 유지 + `lastError` 기록.
- 설정 탭에 Sync 상태 배지/리스트로 노출, 사용자는 재시도 트리거 가능.
- Outbox 누적 시 정기 정리: 오래된 성공/실패 항목 TTL 삭제, 페이로드 압축 고려.

### 4.5 충돌 처리
- 서버 `updated_at` > 로컬 `updatedAt`이면 서버 승(Last write wins). 동시 편집 시 최신 저장 시간 우선.
- 디바이스 시계 불일치 대비: 서버 시간이 기준, 로컬은 참고만.
- 충돌 발생 시 UI 노출 최소화; 필요 시 설정 화면에서 "최근 서버 값으로 덮어쓰기" 안내 정도만 제공.

## 5. Feature 구현 계획 (TCA 관점)
### 5.1 AppFeature / AuthFeature
- State: 세션 상태(authenticated/guest/loading), 온보딩 완료 여부, 초기 동기화 상태, 딥링크 큐.
- Action: `onAppear`, `didFinishOnboarding`, `authResponse`, `deepLinkReceived`, `syncCompleted` 등.
- Effect: Sign in with Apple → Supabase Auth 연동, 프로필 fetch, 기본 캘린더/설정 초기 seed, `SyncClient.pullAll` 호출.
- 게스트 모드: 로컬 전용 데이터로 시작, 로그인 시 계정 매핑 후 미동기화 로컬 데이터 -> 서버 업로드(마이그레이션) 처리.

### 5.2 MainFeature (Tab 루트)
- State: `selectedTab`, `selectedDate`, `userSettings`, 각 탭 child state.
- Action: 탭 전환, 설정 변경 반영, 딥링크 라우팅.
- Effect: 설정 변경 broadcast → 각 child reducer에 dependency로 주입된 `SettingsClient`/`AppearanceSetting` 갱신.

### 5.3 CalendarFeature & 하위
- CalendarFeature(State: viewMode(month/week), visibleRange, filters, dayListState, sheet/detail routing)
  - Actions: 날짜 선택, viewMode 전환, pull-to-refresh, fabTapped.
  - Effects: range 기반 로컬 fetch, 필요 시 `SyncClient.pullRange`.
- DayListFeature: 일/기간 이벤트 리스트, 올데이 우선 정렬 → 시간 순 정렬.
- EventDetailFeature: 조회/편집/복사/삭제 액션 → EventClient 호출, 성공 시 부모에 업데이트 전달.
- EventEditFeature: Form state, 기본값 주입(설정/템플릿), 유효성 검사, 저장 후 Outbox enqueue.
- TemplateListFeature: 템플릿 CRUD, 템플릿→이벤트 생성 액션.
- 의존성: `EventClient`, `CalendarClient`, `SettingsClient`, `SyncClient`.

### 5.4 SearchFeature
- State: query, dateRange, calendarFilter, results.
- Action: queryChanged(debounced), filterChanged, resultSelected(eventId).
- Effect: 로컬 인덱스 쿼리(비동기), 필요 시 최근 구간 Pull 트리거(옵션), 선택 시 EventDetail 라우팅.

### 5.5 SettingsRootFeature 및 자식
- CalendarSettings: 캘린더 목록/색상/기본 여부, 삭제/숨김 처리 → CalendarClient 업데이트.
- AppearanceSettings: 테마/폰트/텍스트 크기/주 시작 요일 등 → AppearanceSettingEntity 저장 후 전역 퍼블리시.
- NotificationSettings: 알림 시점/데일리 요약/배지 → NotificationSettingEntity, 알림 리스케줄.
- AccountSettings: 로그아웃, 데이터 초기화(로컬 DB reset + Outbox purge), 버전/약관 노출.
- WidgetGuide: 위젯 타입/예시, 설정 가이드. WidgetConfig 편집은 별도 화면 또는 설정 내 섹션.

### 5.6 Widget & Notification 연동
- WidgetConfigEntity ↔ WidgetKit: `TimelineProvider`가 SwiftData에서 지정 캘린더/기간 데이터를 읽어 타임라인 생성.
- 알림 payload: `eventRemoteId` 또는 `eventLocalId`를 포함, AppFeature가 수신 시 해당 이벤트 상세로 딥링크.
- Daily Summary: 백그라운드 task에서 오늘/내일 이벤트 요약 생성 후 알림, 배지 업데이트.

## 6. 네비게이션 & 딥링크 설계
- 루트: `TabView` + 각 탭 `NavigationStack`. AppFeature가 탭 선택 및 루트 딥링크를 관리.
- 모달/시트: EventDetail -> `.sheet`, EventEdit -> `.sheet` 또는 `.fullScreenCover`(키보드/폼 집중 필요 시), 온보딩/로그인은 풀스크린.
- 딥링크 규칙: `angelcal://event/<remoteId|localId>`, `angelcal://date/<yyyy-MM-dd>`. AppFeature가 파싱→`MainFeature`에 전달→적절한 탭/스택으로 라우팅.
- 알림/위젯 딥링크도 동일 규칙으로 통합 처리.

## 7. 테스트, 품질, 툴링
- 테스트
  - 도메인/Repository/Sync: Swift Testing 또는 XCTest로 단위 테스트, Supabase API는 mock client, SwiftData는 in-memory 컨테이너.
  - TCA Reducer 테스트: DependencyValues로 클라이언트 주입 후 상태 전이/Effect 검증.
  - UI 스냅샷: 주요 화면(월간/주간/리스트, 검색, 설정) SwiftUI 스냅샷 테스트.
  - UI 통합: 핵심 플로우(온보딩→캘린더→이벤트 생성/수정→검색) UI 테스트.
- 품질/성능
  - 월간/주간 대량 이벤트(예: 1000건/월) 시 60fps 유지 목표. 비동기 fetch + prefetch, 메모리 캐싱 사용.
  - Outbox 대기열 500건 이상 시 배치/청크 전송, 메모리 풋프린트 관리.
- 툴링
- Tuist 템플릿으로 모듈 생성 스크립트.
- SwiftFormat/SwiftLint CI에서 실행, 경미한 규칙으로 TCA 패턴 허용.
- CI 파이프라인 초안: `tuist generate` → `swift build` → `swift test` → lint → (옵션) 스냅샷/UITest → TestFlight 배포.

## 가정/제한/후속 범위
- 위젯 타입 우선순위: v0.1에서 오늘/다가오는/월간 미니/스탠드바이 오늘 3종만 구현, 나머지 타입은 백로그로 유지.
- 공휴일/음력 데이터: 내장 소스(한국 기준)를 번들에 포함하고, 외부 API 동기화는 후속 릴리즈에서 검토.
- WidgetGuide: 타입 소개, 배치/딥링크 예시, 새로고침 주기 안내까지만 포함. 고급 커스터마이즈는 제외.

## 아키텍처 결정 (추가)
- 위젯 데이터 소스는 SwiftData 캐시를 1차로 사용하고, 새로고침 시 SyncClient.pullRange(month span) 후 타임라인 재생성.
- 알림/위젯 오류 처리: 실패 시 백오프 및 마지막 성공 상태 유지, 앱 포그라운드 진입 시 재시도 트리거.

## 단계별 구현 보강
- Settings/Widget 단계: 위젯 타입/캘린더 선택/올데이 포함/최대 이벤트 수 설정 → 타임라인 새로고침/딥링크 검증 → 실패 시 메시지/재시도 UX 포함.
- 오류/재시도 UX: 이벤트 CRUD·Sync·알림/위젯 경로마다 에러 핸들러를 통일해 재시도/취소/로그 기록을 제공.

## 비기능/측정 (추가)
- SC-001~SC-006 측정을 위한 계측 포인트를 App launch/온보딩/이벤트 CRUD/검색/알림·위젯 진입에 추가하고, 로그 포맷을 정의한다.

## 8. 단계별 구현 전략 & 마일스톤
- **1단계: 인프라/뼈대**
  - Tuist 프로젝트 및 모듈 생성, Shared/Core/Data 스켈레톤.
  - SupabaseClient/SwiftDataClient 초기화, OutboxEntity 정의, 기본 SyncService 틀.
  - AppFeature/MainFeature 루트와 더미 달력 뷰로 탭 구조 시연.
- **2단계: 캘린더·이벤트 기본 CRUD**
  - CalendarFeature/DayList/EventDetail/EventEdit MVP.
  - Event/Calendar Repository + Push/Pull 기본 흐름, 오프라인 CRUD 및 재연결 검증.
- **3단계: 검색·템플릿·설정**
  - SearchFeature 구현 및 성능 튜닝, 로컬 인덱스 구축.
  - TemplateListFeature 연동, Settings 하위 Feature(캘린더/외관/알림/계정/위젯 가이드) 구현.
- **4단계: 위젯·알림·폴리싱**
  - WidgetKit 타임라인, WidgetConfig 저장/반영.
  - 이벤트 알림, Daily Summary, 배지 업데이트.
  - 성능/UX 폴리싱, 동기화 에러 핸들링, 다기기 단순 충돌 검증.

각 단계 완료 시점에 데모 가능 상태 확보: 1) 기본 뼈대 구동, 2) 오프라인 포함 CRUD 동작, 3) 검색/설정/템플릿 동작, 4) 위젯·알림 포함 실제 사용 가능 MVP.

## 9. 열린 결정(Plan 관점)
- 위젯 타입 우선순위: 월간/오늘/다가오는 중 어떤 것을 1차에 넣을지 제품 측 확정 필요.
- 검색 인덱싱 범위: Spotlight 연동 여부, 로컬 인덱스 필드 확장 여부 결정 필요.
- 요금제/프로 기능: 현재 제외, 후속 버전에서 별도 설계.
