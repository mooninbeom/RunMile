# Run Mile

건강 앱에 쌓인 러닝 기록으로 러닝화의 마일리지를 관리하고,
한 번의 러닝을 더 자세히 돌아보는 iOS 러닝 기록 앱입니다.

[App Store에서 Run Mile 만나기](https://apps.apple.com/kr/app/run-mile/id6747099791)

| 항목 | 내용 |
| :-- | :-- |
| 최신 버전 | 2.0.1 |
| 플랫폼 | iOS |
| 주요 기술 | SwiftUI, HealthKit, Core Data, MapKit, Vision, UserNotifications |
| 문의 | dlsqja567@naver.com |

## 앱 미리보기

<img width="6420" height="2778" alt="Group 1" src="https://github.com/user-attachments/assets/720fefc2-2e6f-4e27-a2dc-57ef56a5b05c" />


## Run Mile로 할 수 있는 일

### 러닝화 마일리지 관리

러닝화를 등록하고 목표 마일리지를 설정하세요. 운동 기록을 연결하면 신발별 누적 거리와 교체 시점을 한눈에 확인할 수 있습니다.

- 브랜드, 모델, 별명, 용도, 목표 마일리지 관리
- 운동 기록을 선택해 신발별 마일리지로 등록
- 목표 마일리지 달성 알림
- 사진에서 신발을 더 돋보이게 정리하는 이미지 처리 지원

### 운동 기록 자동 등록

자주 신는 러닝화를 자동 등록 신발로 설정할 수 있습니다. 새로운 러닝 운동이 건강 앱에 추가되면, 설정한 신발에 마일리지를 자동으로 반영하고 결과를 알려줍니다.

- 자동 등록 신발 선택
- 자동 등록 완료 알림
- 자동 등록을 사용하지 않을 때 수동 등록 안내 알림

> HealthKit의 백그라운드 전달 특성상 반영 시점은 기기 상태와 시스템 환경에 따라 달라질 수 있습니다.

### 러닝 운동 상세 분석

거리와 시간만 확인하는 데서 멈추지 않고, 러닝의 흐름을 살펴볼 수 있습니다.

- 거리, 시간, 평균 페이스, 칼로리 요약
- km별 구간 페이스
- 심박수, 파워, 케이던스, 보폭, 지면 접촉 시간 등 상세 지표
- 고도 변화와 페이스 차트
- 운동 경로와 구간별 페이스 분석 지도

일부 지표와 경로 정보는 Apple Watch, 운동 앱, 기기 설정에 따라 기록된 경우에만 표시됩니다.

### 명예의 전당

목표를 채운 러닝화는 명예의 전당에 졸업시킬 수 있습니다. 졸업한 신발의 기록은 고정되어, 함께 달린 시간과 대표 러닝을 하나의 리포트로 남깁니다.

- 총 마일리지, 러닝 횟수, 함께한 기간과 평균 페이스
- 첫 러닝, 최장 러닝, 마지막 러닝
- 5K, 10K, 하프, 풀코스 구간 최고 기록과 개인 최고 기록(PB) 여부
- 100km, 300km, 500km, 목표 마일리지 등 마일스톤

## 시작하기

1. 건강 데이터 접근 권한을 허용합니다.
2. 함께 달릴 러닝화를 등록합니다.
3. 운동 기록을 신발에 연결하거나 자동 등록 신발을 설정합니다.

## HealthKit 활용

Run Mile은 건강 앱의 러닝 운동 기록을 읽어 운동 목록, 운동 상세 분석, 신발별 마일리지를 구성합니다. 건강 데이터는 기기 안에서 관리되며, 앱은 서비스 제공에 필요한 권한만 요청합니다.

## 기술 구성

- UI: SwiftUI
- 운동 데이터: HealthKit
- 로컬 저장: Core Data
- 지도와 경로: MapKit
- 알림: UserNotifications
- 이미지 처리: Vision
- 구조: Clean Architecture + MVVM

## 프로젝트 구조

```text
Run Mile
├── App/Core          # DI, 앱 전역 서비스, 동기화
├── Domain            # Entity, UseCase, Repository Interface
├── Data              # HealthKit, Core Data, Notification 구현
├── Presentation      # SwiftUI View, ViewModel, 화면 구성 요소
└── Helper            # 공통 확장과 보조 기능
```

## 개발 일지

| 주제 | 링크 |
| :-- | :-- |
| 사이드 프로젝트 Run Mile 앱 개발기 | [Velog](https://velog.io/@mooninbeom/0.-사이드-프로젝트-Run-Mile-앱-개발기) |
| HealthKit 데이터 사용 | [Velog](https://velog.io/@mooninbeom/1.-HealthKit-데이터-사용with-Continuation) |
| HealthKit 백그라운드 활용 | [Velog](https://velog.io/@mooninbeom/2.-백그라운드에서-HealthKit-활용하기-o2p1gg9l) |
| Fastlane TestFlight 배포 자동화 | [Velog](https://velog.io/@mooninbeom/3.-Fastlane으로-Testflight-배포-자동화) |

## 문의

기능 제안이나 오류 제보는 `dlsqja567@naver.com`으로 보내주세요.
