# Automated Test Setup

## วิธีติดตั้งและรันโปรเจกต์

1. สร้าง Virtual Environment

```bash
python3 -m venv myvenv
```

2. เปิดใช้งาน Virtual Environment

macOS / Linux

```bash
source myvenv/bin/activate
```

Windows

```bash
myvenv\Scripts\activate
```

3. ติดตั้ง dependencies

```bash
pip install -r requirements.txt
```

4. รัน Robot Framework

```bash
python3 -m robot login.robot
```
