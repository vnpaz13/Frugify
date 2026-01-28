# Frugify

**절약 기록을 통해 소비 습관을 개선하는 iOS 통계 앱**

> Track Your Savings, Grow Your Future
>
https://apps.apple.com/kr/app/frugify-%EC%A0%88%EC%95%BD%EA%B8%B0%EB%A1%9D-%EA%B0%80%EA%B3%84%EB%B6%80/id6757951737

---

## 📱 앱 개요

### ⏱ 작업 기간

- 2025.12.11 ~ 2026.01.16

### 👤 인원

- iOS 1인 개발

### 🧭 앱 성격 / 카테고리

- iOS 개인 금융 / 절약 습관 개선 앱
- 통계 기반 소비 인식 개선 서비스

### 📝 앱 소개

**Frugify**는 사용자가 **‘아낀 소비’만을 기록**하도록 설계된 iOS 앱입니다.

절약한 금액을 **감정과 카테고리로 기록**하고,

**오늘 / 월별 / 전체 통계**를 시각화하여

절약 행동이 **성취감 → 습관**으로 이어지도록 돕습니다.

> 단순 지출 관리가 아닌
> 
> 
> “아낀 경험을 기록하고 강화하는 것”을 핵심 가치로 합니다.
> 

### ✨ 주요 기능

- 홈 화면
    - 절약 기록 추가 (감정 / 카테고리 / 금액)
    - 오늘의 절약 기록
    - 연속 기록 일수(Streak) 뱃지
- 통계 화면
    - 총 절약 금액 (카테고리 별 내역 확인 가능)
    - 월별 통계 (절약 횟수, 금액, 카테고리 별)
    - 감정 통계 (선택 횟수, 금액)
- 설정 화면
    - 닉네임 변경
    - 화면 모드
![Image](https://github.com/user-attachments/assets/a3bd4b17-0752-4b82-aec1-f68d721a9757)

---

## 🛠 기술

### 🧱 아키텍처 소개

**UIKit + MVVM (CallBack Binding)**

- UIKit 기반 코드 레이아웃
- 화면 단위로 `ViewController / ViewModel` 분리
- ViewModel은 **데이터 처리 & 상태 관리**
- ViewController는 **UI 구성 & 바인딩**에 집중

```
ViewController
 ├─ UI 구성
 ├─ 사용자 이벤트 처리
 └─ ViewModel Output 바인딩

ViewModel
 ├─ 비즈니스 로직
 ├─ 네트워크 요청
 ├─ 데이터 가공
 └─ Output(Closure) 전달
```

**Output Callback 방식**

- Rx/Combine 없이도 반응형 업데이트 구현
- 의존성 최소화 + 구조 명확성 확보

예시 : 

```jsx
viewModel.onSummary = { output in
    self.summaryCard.configure(
        totalAmount: output.totalAmount,
        count: output.count
    )
}
```

### 📂 파일 설명 (구조 요약)

### 🔹 App

| 파일명 | 역할 |
| --- | --- |
| `AppDelegate.swift` | 앱 진입점, 기본 라이프사이클 관리 (CoreData 템플릿 포함) |
| `SceneDelegate.swift` | 전역 UI 설정(다크모드) 적용, 초기 Root를 `SplashVC`로 설정 |
| `AppRouter.swift` | 로그인/메인 루트 전환 담당 (Root 교체 + 애니메이션) |
| `TabBarController.swift` | 홈/통계/설정 탭 구성, 재탭 시 스크롤 상단 이동 처리 |

---

### 🔹 Core

| 파일명 | 역할 |
| --- | --- |
| `SupabaseManager.swift` | Supabase 단일 진입점(Auth, DB CRUD, OAuth, Edge Function 호출) |

---

### 🔹 Domian / Entities & DTO

| 파일명 | 역할 |
| --- | --- |
| `NewSavingRecord.swift` | 새 절약 기록 입력용 모델 |
| `SaveEmotion.swift` | 감정 고정 데이터(id, title, symbol) |
| `SaveCategory.swift` | 카테고리 고정 데이터(id, title, color) |
| `YearMonth.swift` | 월 단위 모델(KST 기준 월 범위 계산, 월 리스트 생성) |

| 파일명 | 역할 |
| --- | --- |
| `UserRow.swift` | `users` 테이블 디코딩 모델(프로필) |
| `SavingRecord.swift` | `records` 테이블 디코딩 모델 |
| `CreateRecordRequest.swift` | records insert 요청 모델 |
| `CreateUserRequest.swift` | users insert 요청 모델 |

---

### 🔹 Features / Auth

| 파일명 | 역할 |
| --- | --- |
| `SplashVC.swift` | 스플래시 화면 + 세션 검사 후 루트 분기 |
| `SplashViewModel.swift` | 로그인 세션 유효성 검사 |
| `SignInVC.swift` | 로그인 UI(이메일/소셜) |
| `SignInViewModel.swift` | 로그인 조건 검증 + 로그인 실행 |
| `SignUpVC.swift` | 회원가입 UI(중복확인 포함) |
| `SignUpViewModel.swift` | 회원가입 조건/중복확인/가입 로직 |

---

### 🔹 Features / Main

| 파일명 | 역할 |
| --- | --- |
| `MainVC.swift` | 홈 화면 컨테이너, 하위 컴포넌트 조립 |
| `MainViewModel.swift` | 오늘 기록 조회/저장/삭제, streak 계산 |
| `MainViewModel+TodayDonut.swift` | 오늘 기록 도넛 차트 데이터 생성 |
| `MainHeader.swift` | 상단 날짜/닉네임/streak 표시 |
| `MainNewRecord.swift` | 새 절약 기록 입력 UI |
| `MainNewRecord+Actions.swift` | 기록 저장/초기화/토글 동작 |
| `MainNewRecord+Selection.swift` | 감정/카테고리 단일 선택 로직 |
| `MainNewRecord+ScrollHelper.swift` | 가로 스크롤 UI 헬퍼 |
| `EmotionCard.swift` | 감정 선택 카드 UI |
| `CategoryCard.swift` | 카테고리 선택 카드 UI |
| `AmountMemo.swift` | 금액/메모 입력 컴포넌트 |
| `MainTodaySave.swift` | 오늘 요약(empty ↔ donut 전환) |
| `DonutSummaryCardView.swift` | 도넛 차트 + 범례 UI |
| `MainTodayRecordList.swift` | 오늘 기록 리스트(최대 3개) |
| `TodayRecordCell.swift` | 오늘 기록 셀 UI |
| `TodayEntireVC.swift` | 오늘 기록 전체 목록 화면 |
| `PaddingLabel.swift` | padding 지원 UILabel |

---

### 🔹 Features / Static

| 파일명 | 역할 |
| --- | --- |
| `StaticVC.swift` | 통계 화면 컨테이너 |
| `StaticViewModel.swift` | 전체/월별/감정 통계 계산 |
| `SummaryCardView.swift` | 전체 누적 요약 카드 |
| `MonthlySummaryCardView.swift` | 월 선택 + 카테고리별 통계 |
| `CategoryBarView.swift` | 카테고리 바 차트 UI |
| `CategoryDetailVC.swift` | 카테고리 상세 화면 |
| `CategoryDetailViewModel.swift` | 카테고리별 합산 로직 |
| `EmotionTopView.swift` | 감정 TOP 3 요약 |
| `EmotionTopCardView.swift` | 감정 TOP 카드 UI |
| `EmotionAllStatsSheetVC.swift` | 감정 전체 순위 Sheet |
| `EmotionAmountCardView.swift` | 감정별 절약 금액 카드 |
| `EmotionAmountRowView.swift` | 감정별 금액 Row |
| `ToolTipView.swift` | Tooltip 오버레이/말풍선 UI |

---

### 🔹 Features / Settings

| 파일명 | 역할 |
| --- | --- |
| `SettingVC.swift` | 설정 화면 컨테이너 |
| `SettingViewModel.swift` | 프로필/로그인방식/다크모드/탈퇴 로직 |
| `SettingRowView.swift` | 설정 한 줄(Row) 커스텀 UI |
| `NicknameEditPopupVC.swift` | 닉네임 변경 팝업 |

---

### 🔹 Extensions

| 파일명 | 역할 |
| --- | --- |
| `UIColor+Color.swift` | 앱 공통 컬러 정의 |
| `UIColor+hex.swift` | hex → UIColor 변환 |
| `UITextField+DisableSuggestions.swift` | 키보드 추천/자동완성 비활성화 |
| `UITextField+PlaceHolder.swift` | 포커스 기반 placeholder 제어 |
| `UITextView+DisableSuggestions.swift` | UITextView 추천 비활성화 |
| `UIViewController+Alert.swift` | 공통 Alert |
| `UIViewController+BackButton.swift` | 커스텀 뒤로가기 버튼 |
| `UIViewController+KeyBoard.swift` | 키보드 dismiss 제스처 |
| `UIViewController+Navigation.swift` | 네비게이션바 숨김 |

---

## ⚙️ 사용 기술

- **Language**: Swift
- **UI**: UIKit (Code Layout)
- **Architecture**: MVVM
- **Concurrency**: async / await
- **Backend**: Supabase
- **Auth**: Email / Google / Apple
- **Chart**: CoreAnimation (CAShapeLayer)

### 🤔 기술 선택 이유

- **UIKit**
    - 복잡한 커스텀 UI 및 애니메이션에 유리
- **MVVM**
    - 통계/비즈니스 로직 분리로 유지보수성 확보
- **Output Callback**
    - Rx/Combine 없이도 명확한 단방향 데이터 흐름
- **Supabase**
    - Auth + DB + Edge Function을 단일 백엔드로 관리

---

## 🧠 설계 및 구현 방법

### 1. **📊 데이터 처리 & 통계**

- 오늘 기록: `Calendar.startOfDay`
- 월별 기록:
    - `YearMonth` 모델로 월 개념 명확화
    - UTC ↔ KST 변환 오류 방지를 위해
        
        `YearMonth` 모델 + KST 기준 월 범위 계산 도입
        
        ```swift
        let (start, end)= ym.monthRange(
            in:TimeZone(identifier:"Asia/Seoul")!
        )
        ```
        

### 2. **🧩** 통계 로직 분리 및 UI 구조 설계

- 모든 합계 / 비율 계산을 ViewModel에서 처리
- View는 결과 렌더링만 담당
- 화면을 작은 UI 컴포넌트로 분리하여 유지보수성과 재사용성 향상

### 3. **🗑**  회원 탈퇴 보안 처리

- Supabase Edge Function으로
    
    `auth.users + 관련 데이터` 서버에서 완전 삭제
    
    ```
    App
     → Access Token 획득
     → Edge Function 호출
     → 계정 삭제
     → 로컬 세션 정리
    ```
    

### **4. 📈 시각화 구현**

- **Donut Chart**
    - `CAShapeLayer`로 직접 구현
    - Track + Segment 구조
    - 카테고리별 색상 반영
    - 범례 스크롤 + 고정 카드 높이 설계
- **Category Bar Chart**
    - AutoLayout Constraint 기반 애니메이션
    - 비율에 따라 width 계산
    - 최소 너비 보장으로 가독성 확보

---

## 🚀 앱 배포 및 심사 히스토리

### 📦 릴리즈 노트

### ver 1.0.1 (2026.01.17)

- AppStore Release

### **ver 1.0.2 (2026.01.28)**

- Apple 계정 연동 가입 버튼 한글화
