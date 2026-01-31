# Frugify

**節約記録を通じて消費習慣を改善する iOS 統計アプリ**

> Track Your Savings, Grow Your Future
> 

<a href="https://apps.apple.com/kr/app/frugify-%EC%A0%88%EC%95%BD%EA%B8%B0%EB%A1%9D-%EA%B0%80%EA%B3%84%EB%B6%80/id6757951737">
  <img src="https://github.com/user-attachments/assets/28f482aa-7690-499d-a098-1c45ec0c08db"
       width="40"
       style="vertical-align: middle;" />
</a>
<a href="https://apps.apple.com/kr/app/frugify-%EC%A0%88%EC%95%BD%EA%B8%B0%EB%A1%9D-%EA%B0%80%EA%B3%84%EB%B6%80/id6757951737">
  👈 アプリストアへ
</a>

<div>
<img width= "200" src = "https://github.com/user-attachments/assets/84a5c652-2408-4373-b682-f643715ad58d">
<img width= "200" src = "https://github.com/user-attachments/assets/fb418cf9-32f9-41d3-a219-44d5d6aab1a8">
<img width= "200" src = "https://github.com/user-attachments/assets/de69b2b4-5d96-4ea0-85c1-6adc958e74a7">
<img width= "200" src = "https://github.com/user-attachments/assets/19fa93d9-40e8-40b8-af51-8c61f60a4ce7">
</div>

## 📱 アプリ概要

### ⏱ 開発期間

- 2025.12.11 ~ 2026.01.16

### 👤 開発人数

- iOS 1人開発

### 🧭 アプリの性格 / カテゴリ

- iOS 個人金融 / 節約習慣改善アプリ
- 統計に基づく消費認識改善サービス

### 📝 アプリ紹介

**Frugify** は、ユーザーが **「節約できた消費」だけを記録**するよう設計された iOS アプリです。

節約した金額を **感情** と **カテゴリ** で記録し、

**今日 / 月別 / 全期間の統計** を可視化することで、

節約行動が **達成感 → 習慣** へつながるようサポートします。

> 単なる支出管理ではなく
> 
> 
> 「節約できた体験を記録し、強化していくこと」を中核価値としています。
> 

### ✨ 主な機能

- ホーム画面
    - 節約記録の追加（感情 / カテゴリ / 金額）
    - 今日の節約記録
    - 連続記録日数（Streak）バッジ
- 統計画面
    - 総節約金額（カテゴリ別の内訳確認が可能）
    - 月別統計（節約回数、金額、カテゴリ別）
    - 感情統計（選択回数、金額）
- 設定画面
    - ニックネーム変更
    - 画面モード

---

## 🛠 技術

### 🧱 アーキテクチャ紹介

**UIKit + MVVM（CallBack Binding）**

- UIKit ベースのコードレイアウト
- 画面単位で `ViewController / ViewModel` を分離
- ViewModel は **データ処理 & 状態管理** を担当
- ViewController は **UI 構成 & バインディング** に集中

```
ViewController
 ├─ UI 構成
 ├─ ユーザーイベント処理
 └─ ViewModel Output のバインディング

ViewModel
 ├─ ビジネスロジック
 ├─ ネットワークリクエスト
 ├─ データ加工
 └─ Output（Closure）で通知

```

**Output Callback 方式**

- Rx/Combine なしでもリアクティブな更新を実現
- 依存を最小化しつつ、構造の明確さを確保

例：

```jsx
viewModel.onSummary = { output in
    self.summaryCard.configure(
        totalAmount: output.totalAmount,
        count: output.count
    )
}

```

### 📂 ファイル説明（構造サマリ）

### 🔹 App

| ファイル名 | 役割 |
| --- | --- |
| `AppDelegate.swift` | アプリのエントリーポイント、基本ライフサイクル管理（CoreData テンプレート含む） |
| `SceneDelegate.swift` | グローバル UI 設定（ダークモード）適用、初期 Root を `SplashVC` に設定 |
| `AppRouter.swift` | ログイン/メインのルート切り替え担当（Root 差し替え + アニメーション） |
| `TabBarController.swift` | ホーム/統計/設定タブ構成、再タップ時にスクロールを先頭へ戻す処理 |

---

### 🔹 Core

| ファイル名 | 役割 |
| --- | --- |
| `SupabaseManager.swift` | Supabase の単一エントリーポイント（Auth, DB CRUD, OAuth, Edge Function 呼び出し） |

---

### 🔹 Domain / Entities & DTO

| ファイル名 | 役割 |
| --- | --- |
| `NewSavingRecord.swift` | 新しい節約記録入力用モデル |
| `SaveEmotion.swift` | 感情の固定データ（id, title, symbol） |
| `SaveCategory.swift` | カテゴリの固定データ（id, title, color） |
| `YearMonth.swift` | 月単位モデル（KST 基準の月範囲計算、月リスト生成） |

| ファイル名 | 役割 |
| --- | --- |
| `UserRow.swift` | `users` テーブルのデコードモデル（プロフィール） |
| `SavingRecord.swift` | `records` テーブルのデコードモデル |
| `CreateRecordRequest.swift` | records insert リクエストモデル |
| `CreateUserRequest.swift` | users insert リクエストモデル |

---

### 🔹 Features / Auth

| ファイル名 | 役割 |
| --- | --- |
| `SplashVC.swift` | スプラッシュ画面 + セッション確認後にルート分岐 |
| `SplashViewModel.swift` | ログインセッションの有効性チェック |
| `SignInVC.swift` | ログイン UI（メール / ソーシャル） |
| `SignInViewModel.swift` | ログイン条件検証 + ログイン実行 |
| `SignUpVC.swift` | 会員登録 UI（重複確認を含む） |
| `SignUpViewModel.swift` | 会員登録の条件/重複確認/登録ロジック |

---

### 🔹 Features / Main

| ファイル名 | 役割 |
| --- | --- |
| `MainVC.swift` | ホーム画面コンテナ、下位コンポーネントを組み立て |
| `MainViewModel.swift` | 今日の記録取得/保存/削除、streak 計算 |
| `MainViewModel+TodayDonut.swift` | 今日の記録ドーナツチャート用データ生成 |
| `MainHeader.swift` | 上部の日付/ニックネーム/streak 表示 |
| `MainNewRecord.swift` | 新しい節約記録入力 UI |
| `MainNewRecord+Actions.swift` | 記録の保存/初期化/トグル動作 |
| `MainNewRecord+Selection.swift` | 感情/カテゴリの単一選択ロジック |
| `MainNewRecord+ScrollHelper.swift` | 横スクロール UI ヘルパー |
| `EmotionCard.swift` | 感情選択カード UI |
| `CategoryCard.swift` | カテゴリ選択カード UI |
| `AmountMemo.swift` | 金額/メモ入力コンポーネント |
| `MainTodaySave.swift` | 今日のサマリー（empty ↔ donut 切り替え） |
| `DonutSummaryCardView.swift` | ドーナツチャート + 凡例 UI |
| `MainTodayRecordList.swift` | 今日の記録リスト（最大 3 件） |
| `TodayRecordCell.swift` | 今日の記録セル UI |
| `TodayEntireVC.swift` | 今日の記録全件一覧画面 |
| `PaddingLabel.swift` | padding 対応 UILabel |

---

### 🔹 Features / Static

| ファイル名 | 役割 |
| --- | --- |
| `StaticVC.swift` | 統計画面コンテナ |
| `StaticViewModel.swift` | 全期間/月別/感情の統計計算 |
| `SummaryCardView.swift` | 全期間の累積サマリーカード |
| `MonthlySummaryCardView.swift` | 月選択 + カテゴリ別統計 |
| `CategoryBarView.swift` | カテゴリのバーチャート UI |
| `CategoryDetailVC.swift` | カテゴリ詳細画面 |
| `CategoryDetailViewModel.swift` | カテゴリ別合算ロジック |
| `EmotionTopView.swift` | 感情 TOP 3 サマリー |
| `EmotionTopCardView.swift` | 感情 TOP カード UI |
| `EmotionAllStatsSheetVC.swift` | 感情の全ランキング Sheet |
| `EmotionAmountCardView.swift` | 感情別節約金額カード |
| `EmotionAmountRowView.swift` | 感情別金額 Row |
| `ToolTipView.swift` | Tooltip オーバーレイ/吹き出し UI |

---

### 🔹 Features / Settings

| ファイル名 | 役割 |
| --- | --- |
| `SettingVC.swift` | 設定画面コンテナ |
| `SettingViewModel.swift` | プロフィール/ログイン方式/ダークモード/退会ロジック |
| `SettingRowView.swift` | 設定の1行（Row）カスタム UI |
| `NicknameEditPopupVC.swift` | ニックネーム変更ポップアップ |

---

### 🔹 Extensions

| ファイル名 | 役割 |
| --- | --- |
| `UIColor+Color.swift` | アプリ共通カラー定義 |
| `UIColor+hex.swift` | hex → UIColor 変換 |
| `UITextField+DisableSuggestions.swift` | キーボードの候補/自動補完の無効化 |
| `UITextField+PlaceHolder.swift` | フォーカスに応じた placeholder 制御 |
| `UITextView+DisableSuggestions.swift` | UITextView の候補無効化 |
| `UIViewController+Alert.swift` | 共通 Alert |
| `UIViewController+BackButton.swift` | カスタム戻るボタン |
| `UIViewController+KeyBoard.swift` | キーボード dismiss ジェスチャー |
| `UIViewController+Navigation.swift` | ナビゲーションバー非表示 |

---

## ⚙️ 使用技術

- **Language**: Swift
- **UI**: UIKit（Code Layout）
- **Architecture**: MVVM
- **Concurrency**: async / await
- **Backend**: Supabase
- **Auth**: Email / Google / Apple
- **Chart**: CoreAnimation（CAShapeLayer）

### 🤔 技術選定理由

- **UIKit**
    - 複雑なカスタム UI やアニメーションに強い
- **MVVM**
    - 統計/ビジネスロジックを分離し、保守性を確保
- **Output Callback**
    - Rx/Combine なしでも明確な単方向データフローを実現
- **Supabase**
    - Auth + DB + Edge Function を単一バックエンドで一括管理

---

## 🧠 設計・実装方針

### 1. **📊 データ処理 & 統計**

- 今日の記録: `Calendar.startOfDay`
- 月別記録:
    - `YearMonth` モデルで「月」の概念を明確化
    - UTC ↔ KST の変換ミスを防ぐために
        
        `YearMonth` モデル + KST 基準の月範囲計算を導入
        
        ```swift
        let (start, end)= ym.monthRange(
            in:TimeZone(identifier:"Asia/Seoul")!
        )
        
        ```
        

### 2. **🧩** 統計ロジックの分離と UI 構造設計

- すべての合計/比率計算を ViewModel で処理
- View は結果のレンダリングのみを担当
- 画面を小さな UI コンポーネントに分割し、保守性と再利用性を向上

### 3. **🗑** 退会時のセキュアな削除処理

- Supabase Edge Function を用いて
    
    `auth.users + 関連データ` をサーバー側で完全削除
    
    ```
    App
     →Access Token 取得
     → EdgeFunction 呼び出し
     → アカウント削除
     → ローカルセッション整理
    
    ```
    

### 4. **📈 可視化の実装**

- **Donut Chart**
    - `CAShapeLayer` で自作実装
    - Track + Segment 構造
    - カテゴリ別カラーを反映
    - 凡例スクロール + 固定カード高さ設計
- **Category Bar Chart**
    - AutoLayout Constraint ベースのアニメーション
    - 比率に応じて width を計算
    - 最小幅を保証して可読性を確保

---

## 🚀 アプリ配布・審査履歴

### ver 1.0.1（2026.01.17）

- AppStore Release

### **ver 1.0.2（2026.01.28）**

- Apple アカウント連携の登録ボタンを日本語化し、細部 UI を調整

---

## 📌 今後の改善方針

- `SupabaseManager` をドメイン別サービスへ分割
- Rx/Combine ベースで ViewModel を拡張
- チャートアニメーションの高度化
- 感情・カテゴリの横スクロールビュー UI 改善
- コミュニティセクション追加

## 🛠️ 今後のアップデート予定

- 全記録の閲覧機能を追加
- 記録編集（Edit）機能を追加
- 感情・カテゴリのカスタマイズ機能を追加
