# SnakeYAML이나 다른 라이브러리에서 사용하는 java.beans 미지원 클래스 무시
-dontwarn java.beans.**
-keep class java.beans.** { *; }

# R8 빌드 시 발생하는 누락된 클래스 에러 방지
-ignorewarnings