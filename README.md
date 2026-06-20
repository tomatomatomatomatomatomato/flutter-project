# 🏢 낙서몬 아파트 (OddyRoom)

## 1. 프로그램 개요

낙서몬 아파트(OddyRoom)는 Flutter를 활용하여 제작한 캐릭터 육성 및 상호작용 애플리케이션입니다.

사용자는 직접 도트 캐릭터를 제작한 뒤 아파트의 방에 입주시킬 수 있으며, 캐릭터의 상태를 관리하고 다양한 상호작용을 경험할 수 있습니다.

캐릭터는 성격에 따라 서로 다른 대사를 출력하고, 다른 방의 캐릭터가 방문하는 이벤트가 발생하기도 합니다. 또한 미니게임을 통해 재화를 획득하고, 간식과 장난감을 구매하여 캐릭터를 돌보는 육성 요소를 추가하였습니다.

귀엽고 친근한 캐릭터 브랜딩과 수집 요소를 통해 사용자가 지속적으로 확인하고 관리하고 싶어지는 앱을 목표로 제작하였습니다.

---

## 2. 주요 기능

### 🎨 캐릭터 생성 기능

* 24×24 도트 에디터 제공
* 브러시, 채우기, 지우개 기능 지원
* RGB 색상 조절 기능 지원
* 캐릭터 이름 및 성격 설정

### 🏠 방 배치 시스템

* 최대 6개의 방 제공
* 원하는 방에 캐릭터 입주 가능
* 방별 캐릭터 관리

### 😊 캐릭터 상태 시스템

* 행복도 시스템
* 배고픔 시스템
* 상태에 따른 대사 변화

### 💬 성격 기반 대사 시스템

* 멍함
* 예민함
* 활발함
* 이상함
* 소심함
* 장난꾸러기
* 철학적임

성격에 따라 서로 다른 랜덤 대사를 출력합니다.

### 🚶 캐릭터 행동 시스템

* 랜덤 이동
* 점프 애니메이션
* 수면 상태
* 방문 손님 이벤트

### 🍪 간식 상점 시스템

* 쿠키
* 우유
* 케이크

간식마다 가격, 포만도, 행복도 증가량이 다르게 설정되어 있습니다.

### 🧸 장난감 시스템

* 곰 인형
* 블록 장난감
* 삐걱 로봇 등

장난감을 구매하여 사용하면 행복도가 증가합니다.

### 🎮 미니게임 시스템

* 무한의 계단 스타일 미니게임
* 좌우 이동 방식
* 제한 시간 시스템
* 보너스 아이템 획득

  * ⏰ 시간 증가
  * 🪙 보너스 코인
* 점수에 따라 코인 획득

### 💰 재화 시스템

* 코인 획득
* 상점 구매
* 재화 소비

### 💾 데이터 저장 시스템

* SharedPreferences 활용
* 캐릭터 정보 저장
* 방 정보 저장
* 코인 저장
* 간식 보유량 저장
* 장난감 보유 정보 저장

앱을 종료해도 데이터가 유지됩니다.

---

## 3. 기술 스택

* Flutter
* Dart
* SharedPreferences

---

## 4. 실행 화면

<table>
<tr>
<td><img src="https://github.com/tomatomatomatomatomatomato/flutter-project/blob/main/OddyRoom_1.png" width="250"/></td>
<td><img src="https://github.com/tomatomatomatomatomatomato/flutter-project/blob/main/OddyRoom_2.png" width="250"/></td>
</tr>

<tr>
<td><img src="https://github.com/tomatomatomatomatomatomato/flutter-project/blob/main/OddyRoom_3.png" width="250"/></td>
<td><img src="https://github.com/tomatomatomatomatomatomato/flutter-project/blob/main/OddyRoom_4.png" width="250"/></td>
</tr>

<tr>
<td><img src="https://github.com/tomatomatomatomatomatomato/flutter-project/blob/main/OddyRoom_5.png" width="250"/></td>
<td><img src="https://github.com/tomatomatomatomatomatomato/flutter-project/blob/main/OddyRoom_6.png" width="250"/></td>
</tr>

<tr>
<td><img src="https://github.com/tomatomatomatomatomatomato/flutter-project/blob/main/OddyRoom_7.png" width="250"/></td>
<td><img src="https://github.com/tomatomatomatomatomatomato/flutter-project/blob/main/OddyRoom_8.png" width="250"/></td>
</tr>
</table>

---

## 5. 본인이 구현한 부분

* 프로젝트 아이디어 기획
* 캐릭터 육성 시스템 설계
* UI 구조 설계
* 기능 요구사항 정의
* 캐릭터 상태 시스템 설계
* 상점 시스템 기획
* 미니게임 기획
* 테스트 및 기능 검증
* GitHub 저장소 관리

---

## 6. AI 활용 여부 및 활용 범위

본 프로젝트는 AI 기반 개발 방식(Vibe Coding)을 활용하여 제작되었습니다.

ChatGPT를 활용하여 Flutter 코드 작성, 기능 구현, 오류 수정, UI 개선 및 리팩토링을 진행하였습니다.

프로젝트의 아이디어 선정, 기능 기획, UX 방향 설정, 시스템 구성 및 최종 의사결정은 개발자가 직접 수행하였습니다.

---

## 7. 향후 개선 사항

* 가구 배치 시스템
* 캐릭터 꾸미기 기능
* 장난감 종류 추가
* 캐릭터 호감도 시스템
* 방문 이벤트 확장
* 업적 및 수집 요소 추가

---

## 8. 라이선스

MIT License

본 프로젝트는 학습 및 과제 제출 목적으로 제작되었습니다.
