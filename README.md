# Frugify

**절약 기록을 통해 소비 습관을 개선하는 iOS 통계 앱**

> *Track Your Savings, Grow Your Future*

---

## 📱 앱 소개

**Frugify**는 사용자가 **절약한 금액을 감정과 카테고리로 기록**하고,
**오늘 / 월별 / 전체 통계**를 시각화하여 **절약 습관의 지속**을 돕는 iOS 앱입니다.

단순 가계부가 아닌,

> “아낀 소비를 기록하고 → 성취감을 느끼게 하는 것”
> 을 핵심 가치로 설계되었습니다.

---

## 🧱 아키텍처

### UIKit + MVVM (Callback Binding)

* UIKit 기반 앱
* 화면 단위로 `ViewController + ViewModel` 분리
* ViewModel은 **데이터 로딩 / 가공 / 상태 관리**
* ViewController는 **UI 구성 / 이벤트 연결 / 렌더링**에 집중

```text
ViewController
 ├─ UI 구성
 ├─ 사용자 이벤트 처리
 └─ ViewModel Output 바인딩

ViewModel
 ├─ 비즈니스 로직
 ├─ 네트워크 요청
 ├─ 데이터 가공
 └─ Output(closure) 전달
```

### Output Callback 방식

* Combine/Rx 없이도 반응형 업데이트 구현
* 의존성 최소화 + 구조 명확성 확보

예시:

```swift
viewModel.onSummary = { output in
    self.summaryCard.configure(
        totalAmount: output.totalAmount,
        count: output.count
    )
}
```

---

## 🧩 UI 구조 설계

### 컴포넌트 단위 분리 (Composable UI)

화면을 “작은 UI 컴포넌트”로 분리하여 유지보수성과 재사용성을 높였습니다.

**Home**

* `MainHeader`
* `MainNewRecord`
* `MainTodaySave`
* `MainTodayRecordList`

**Statistics**

* `SummaryCardView`
* `MonthlySummaryCardView`
* `EmotionTopView`
* `EmotionAmountCardView`

**Cells / Rows**

* `TodayRecordCell`
* `CategoryBarView`
* `EmotionTopCardView`
* `EmotionAmountRowView`

> ViewController는 컴포넌트를 **조립하는 역할**만 수행합니다.

---

## 🔐 인증 & 백엔드

### Supabase 기반 구조

* `SupabaseManager`를 단일 데이터 게이트웨이로 사용
* 인증 / DB / Edge Function 호출을 통합 관리

#### 인증

* 이메일 / 비밀번호 로그인
* Google OAuth
* Apple Sign In
* 딥링크 기반 OAuth 리다이렉트
  `frugify://auth-callback`

#### 주요 테이블

* `users` → 사용자 프로필
* `records` → 절약 기록

---

## 🗑 회원 탈퇴 (Advanced)

* Supabase Edge Function을 사용하여
  **auth.users + 관련 데이터 완전 삭제**
* 클라이언트에서 직접 처리하지 않고
  **서버 권한 작업을 분리**하여 보안 강화

```text
App
 → Access Token 획득
 → Edge Function 호출
 → 계정 삭제
 → 로컬 세션 정리
```

---

## 📊 데이터 처리 & 통계

### 날짜 / 월 계산의 정확성

* 오늘 기록: `Calendar.startOfDay`
* 월별 기록:

  * `YearMonth` 모델로 월 개념 명확화
  * **KST 기준 월 범위 계산**
  * UTC 변환 오류 방지

```swift
let (start, end) = ym.monthRange(in: TimeZone(identifier: "Asia/Seoul")!)
```

### 통계 로직 분리

* ViewModel에서 모든 합계/비율 계산
* View는 결과를 그대로 렌더링만 수행

---

## 📈 시각화 구현

### Donut Chart

* `CAShapeLayer`로 직접 구현
* Track + Segment 구조
* 카테고리별 색상 반영
* 범례 스크롤 + 고정 카드 높이 설계

### Category Bar Chart

* AutoLayout Constraint 기반 애니메이션
* 비율에 따라 width 계산
* 최소 너비 보장으로 가독성 확보

---

## 🎯 UX 설계 포인트

* 기록 저장 시 즉시:

  * 오늘 요약 갱신
  * 리스트 갱신
  * 연속 기록(Streak) 갱신
* Empty / Data 상태 분리
* 탭 재선택 시 스크롤 최상단 이동
* 키보드 dismiss 공통 처리
* Tooltip 오버레이 직접 구현

---

## 🧠 기술 스택

* **Language**: Swift
* **UI**: UIKit, AutoLayout
* **Architecture**: MVVM
* **Concurrency**: async / await
* **Backend**: Supabase
* **Auth**: Email / Google / Apple
* **Chart**: CoreAnimation (CAShapeLayer)

---

## 🔍 설계에서 고민한 점

* Combine 없이도 MVVM 구조를 유지하는 방법
* 통계 앱에서 “날짜/시간대” 오류를 피하는 구조
* UI 컴포넌트를 어떻게 쪼개야 재사용성이 좋아지는지
* 서버 권한 작업(회원 탈퇴)을 클라이언트에서 분리하는 방식

---

## 🚀 향후 개선 방향

* `SupabaseManager`를 도메인별 서비스로 분리
* 기록 수정(Edit) 기능 추가
* Combine 기반 ViewModel 확장
* 차트 애니메이션 고도화

---

## 🧾 한 줄 요약 (Resume용)

> **UIKit 기반 MVVM 구조로 절약 기록 앱을 설계하고, Supabase Auth/DB 및 CoreAnimation 차트를 직접 구현한 iOS 프로젝트**

---
