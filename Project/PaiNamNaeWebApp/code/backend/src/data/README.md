# Password Word List

วางไฟล์ `common_passwords.txt` ในโฟลเดอร์นี้

## รูปแบบไฟล์

- รหัสผ่าน 1 คำต่อบรรทัด
- ตัวพิมพ์เล็กหรือใหญ่ก็ได้ (ระบบจะแปลงเป็น lowercase เอง)
- บรรทัดว่างจะถูก ignore อัตโนมัติ
- ใส่ comment ด้วย `#` นำหน้าได้

## แหล่งที่มาที่แนะนำ

- [SecLists/Passwords](https://github.com/danielmiessler/SecLists/tree/master/Passwords) — rockyou.txt (14M), top-passwords-shortlist.txt (250K)
- [NCSC UK Top 100K](https://www.ncsc.gov.uk/static-assets/documents/PwnedPasswordsTop100k.txt)
- [HaveIBeenPwned](https://haveibeenpwned.com/Passwords) — Pwned Passwords list

## ตัวอย่าง

```
123456
password
qwerty123
iloveyou
...
```

## หมายเหตุ

ไฟล์นี้ไม่ได้อยู่ใน git repository (อยู่ใน .gitignore) เนื่องจากขนาดใหญ่
ต้องวางไฟล์เองก่อน start server — ถ้าไม่มีไฟล์ ระบบจะใช้ fallback list ขนาดเล็กแทน
